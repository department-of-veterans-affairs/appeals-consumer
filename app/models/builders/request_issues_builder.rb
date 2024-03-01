# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues
class Builders::RequestIssuesBuilder
  include ModelBuilder
  attr_reader :decision_review_created, :issue, :index, :request_issue

  REQUEST_ISSUE = "RequestIssue"
  HLR_DECISION_REVIEW_TYPE = "HIGHER_LEVEL_REVIEW"

  # the date AMA was launched
  # used to determine if "TIME_RESTRICTION" eligibility_result matches "before_ama" or "untimely" ineligible_reason
  AMA_ACTIVATION_DATE = Date.new(2019, 2, 19)

  # issues with this eligibility_result are not included in the caseflow payload
  # caseflow does not track or have a concept of this when determining ineligible_reason
  CONTESTED = "CONTESTED"

  # eligibility_result values that have a 1-to-1 match to a Request Issue ineligible_reason
  TIME_RESTRICTION = "TIME_RESTRICTION"
  COMPLETED_HLR = "COMPLETED_HLR"
  COMPLETED_BOARD = "COMPLETED_BOARD"
  PENDING_LEGACY_APPEAL = "PENDING_LEGACY_APPEAL"

  # eligibility_result values grouped by Request Issue ineligible_reason
  COMPLETED_REVIEW = %w[COMPLETED_BOARD COMPLETED_HLR].freeze
  PENDING_REVIEW = %w[PENDING_HLR PENDING_BOARD PENDING_SUPPLEMENTAL].freeze
  LEGACY_APPEAL_NOT_ELIGIBLE = %w[LEGACY_TIME_RESTRICTION NO_SOC_SSOC].freeze

  # eligibility_result values grouped by ineligible and eligible
  ELIGIBLE = %w[ELIGIBLE ELIGIBLE_LEGACY].freeze
  INELIGIBLE = %w[
    TIME_RESTRICTION PENDING_LEGACY_APPEAL LEGACY_TIME_RESTRICTION NO_SOC_SSOC
    PENDING_HLR COMPLETED_HLR PENDING_BOARD COMPLETED_BOARD PENDING_SUPPLEMENTAL
  ].freeze

  INELIGIBLE_CLOSED_STATUS = "ineligible"
  INELIGIBLE_REASONS = {
    duplicate_of_nonrating_issue_in_active_review: "duplicate_of_nonrating_issue_in_active_review",
    duplicate_of_rating_issue_in_active_review: "duplicate_of_rating_issue_in_active_review",
    untimely: "untimely",
    higher_level_review_to_higher_level_review: "higher_level_review_to_higher_level_review",
    appeal_to_higher_level_review: "appeal_to_higher_level_review",
    before_ama: "before_ama",
    legacy_issue_not_withdrawn: "legacy_issue_not_withdrawn",
    legacy_appeal_not_eligible: "legacy_appeal_not_eligible"
  }.freeze

  def self.build(decision_review_created)
    builder = new(decision_review_created)

    issues = []
    builder.build_issues(issues)
    issues
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
  end

  def build_issues(issues)
    valid_issues = remove_ineligible_contested_issues

    if valid_issues.empty?
      handle_no_issues_after_removing_contested
    else
      valid_issues.each_with_index do |issue, index|
        build_request_issue(issue, issues, index)
      end
    end
  end

  private

  # removes "CONTESTED" issues from final array
  # caseflow does not track or have a concept of this when determining ineligible_reason
  def remove_ineligible_contested_issues
    decision_review_created.decision_review_issues.reject { |issue| issue.eligibility_result == CONTESTED }
  end

  def handle_no_issues_after_removing_contested
    fail AppealsConsumer::Error::NoIssuesFound, "DecisionReviewCreated Claim ID #{decision_review_created.claim_id}"\
     " does not contain any valid issues after removing 'CONTESTED' ineligible issues"
  end

  def build_request_issue(issue, issues, index)
    initialize_issue(issue, index)
    assign_attributes
    issues << @request_issue
  end

  def initialize_issue(issue, index)
    @issue = issue
    @index = index
    @request_issue = RequestIssue.new
  end

  def assign_attributes
    assign_methods
    calculate_methods
  end

  def assign_methods
    assign_contested_rating_decision_reference_id
    assign_contested_rating_issue_reference_id
    assign_contested_decision_issue_id
    assign_is_unidentified
    assign_untimely_exemption
    assign_untimely_exemption_notes
    assign_vacols_id
    assign_vacols_sequence_id
    assign_nonrating_issue_bgs_id
    assign_type
  end

  def calculate_methods
    calculate_contention_reference_id
    calculate_benefit_type
    calculate_contested_issue_description
    calculate_contested_rating_issue_profile_date
    calculate_decision_date
    calculate_ineligible_due_to_id
    calculate_ineligible_reason
    calculate_unidentified_issue_text
    calculate_nonrating_issue_category
    calculate_nonrating_issue_description
    calculate_closed_at
    calculate_closed_status
    calculate_contested_rating_issue_diagnostic_code
    calculate_ramp_claim_id
    calculate_rating_issue_associated_at
  end

  def calculate_benefit_type
    @request_issue.benefit_type = determine_benefit_type
  end

  def calculate_contested_issue_description
    @request_issue.contested_issue_description =
      rating_or_decision_issue? ? remove_duplicate_prior_decision_type_text : nil
  end

  def calculate_contention_reference_id
    @request_issue.contention_reference_id =
      if eligible?
        handle_missing_contention_id if contention_id_not_present?

        issue.contention_id
      elsif ineligible?
        handle_contention_id_present if contention_id_present?

        nil
      end
  end

  def assign_contested_rating_decision_reference_id
    @request_issue.contested_rating_decision_reference_id = issue.prior_decision_rating_disability_sequence_number
  end

  def calculate_contested_rating_issue_profile_date
    @request_issue.contested_rating_issue_profile_date = rating? ? issue.prior_decision_rating_profile_date : nil
  end

  def assign_contested_rating_issue_reference_id
    @request_issue.contested_rating_issue_reference_id = issue.prior_rating_decision_id&.to_s
  end

  def assign_contested_decision_issue_id
    @request_issue.contested_decision_issue_id = issue.associated_caseflow_decision_id
  end

  # TODO: change to new field used for prior_decision_notification_date - 1 business day
  def calculate_decision_date
    handle_missing_notification_date if prior_decision_notification_date_not_present? && identified?

    @request_issue.decision_date = issue.prior_decision_notification_date
  end

  def calculate_ineligible_due_to_id
    @request_issue.ineligible_due_to_id =
      if pending_claim_review?
        handle_associated_request_issue_not_present

        issue.associated_caseflow_request_issue_id
      end
  end

  def calculate_ineligible_reason
    @request_issue.ineligible_reason = determine_ineligible_reason
  end

  def assign_is_unidentified
    @request_issue.is_unidentified = unidentified?
  end

  def calculate_unidentified_issue_text
    @request_issue.unidentified_issue_text =  unidentified? ? issue.prior_decision_text : nil
  end

  def calculate_nonrating_issue_category
    @request_issue.nonrating_issue_category = nonrating? ? issue.prior_decision_type : nil
  end

  def calculate_nonrating_issue_description
    @request_issue.nonrating_issue_description =
      if nonrating? && !decision_issue?
        remove_duplicate_prior_decision_type_text
      end
  end

  def assign_untimely_exemption
    @request_issue.untimely_exemption = !!issue.time_override
  end

  def assign_untimely_exemption_notes
    @request_issue.untimely_exemption_notes = issue.time_override_reason
  end

  def assign_vacols_id
    @request_issue.vacols_id = issue.legacy_appeal_id
  end

  def assign_vacols_sequence_id
    @request_issue.vacols_sequence_id = issue.legacy_appeal_issue_id
  end

  def assign_type
    @request_issue.type = REQUEST_ISSUE
  end

  def calculate_closed_at
    @request_issue.closed_at = ineligible? ? decision_review_created.claim_creation_time : nil
  end

  def calculate_closed_status
    @request_issue.closed_status = ineligible? ? INELIGIBLE_CLOSED_STATUS : nil
  end

  def calculate_contested_rating_issue_diagnostic_code
    @request_issue.contested_rating_issue_diagnostic_code = rating? ? issue.prior_decision_diagnostic_code : nil
  end

  def calculate_ramp_claim_id
    @request_issue.ramp_claim_id = rating? ? issue.prior_decision_ramp_id : nil
  end

  def calculate_rating_issue_associated_at
    @request_issue.rating_issue_associated_at =
      if rating? && eligible?
        decision_review_created.claim_creation_time
      end
  end

  def assign_nonrating_issue_bgs_id
    @request_issue.nonrating_issue_bgs_id = issue.prior_non_rating_decision_id&.to_s
  end

  def determine_ineligible_reason
    if eligible?
      nil
    elsif pending_claim_review?
      determine_pending_claim_review_type
    elsif time_restriction?
      determine_time_restriction_type
    elsif completed_claim_review?
      determine_completed_claim_review_type
    elsif pending_legacy_appeal?
      legacy_issue_not_withdrawn
    elsif legacy_time_restriction_or_no_soc_ssoc?
      legacy_appeal_not_eligible
    else
      handle_unrecognized_eligibility_result
    end
  end

  def duplicate_of_nonrating_issue_in_active_review
    INELIGIBLE_REASONS[:duplicate_of_nonrating_issue_in_active_review]
  end

  def duplicate_of_rating_issue_in_active_review
    INELIGIBLE_REASONS[:duplicate_of_rating_issue_in_active_review]
  end

  def untimely
    INELIGIBLE_REASONS[:untimely]
  end

  def higher_level_review_to_higher_level_review
    INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review]
  end

  def appeal_to_higher_level_review
    INELIGIBLE_REASONS[:appeal_to_higher_level_review]
  end

  def before_ama
    INELIGIBLE_REASONS[:before_ama]
  end

  def legacy_issue_not_withdrawn
    INELIGIBLE_REASONS[:legacy_issue_not_withdrawn]
  end

  def legacy_appeal_not_eligible
    INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
  end

  def handle_associated_request_issue_not_present
    unless associated_caseflow_request_issue_present?
      fail AppealsConsumer::Error::NullAssociatedCaseflowRequestIssueId, "DecisionReviewCreated Claim ID"\
      " #{decision_review_created.claim_id} - Issue index #{index} has a null associated_caseflow_request_issue_id"
    end
  end

  def remove_duplicate_prior_decision_type_text
    category = issue.prior_decision_type
    return issue.prior_decision_text unless category

    category += ": "
    description = issue.prior_decision_text

    description.gsub(/#{Regexp.escape(category)}/i, "")
  end

  def rating_or_decision_issue?
    rating? || rating_decision? || decision_issue?
  end

  def pending_claim_review?
    PENDING_REVIEW.include?(issue.eligibility_result)
  end

  def time_restriction?
    issue.eligibility_result == TIME_RESTRICTION
  end

  def pending_legacy_appeal?
    issue.eligibility_result == PENDING_LEGACY_APPEAL
  end

  def legacy_time_restriction_or_no_soc_ssoc?
    LEGACY_APPEAL_NOT_ELIGIBLE.include?(issue.eligibility_result)
  end

  def completed_board?
    issue.eligibility_result == COMPLETED_BOARD
  end

  # TODO: change to new field used for prior_decision_notification_date - 1 business day
  def decision_date_before_ama?
    decision_date = issue.prior_decision_notification_date

    if decision_date
      ama_activation_date_logical_type = (AMA_ACTIVATION_DATE - EPOCH_DATE).to_i
      decision_date < ama_activation_date_logical_type
    end
  end

  def associated_caseflow_request_issue_present?
    !!issue.associated_caseflow_request_issue_id
  end

  def identified?
    rating? || rating_decision? || nonrating?
  end

  # TODO: change to new field used for prior_decision_notification_date - 1 business day
  def prior_decision_notification_date_not_present?
    !issue.prior_decision_notification_date
  end

  def contention_id_not_present?
    !issue.contention_id
  end

  def ineligible?
    INELIGIBLE.include?(issue.eligibility_result)
  end

  def eligible?
    ELIGIBLE.include?(issue.eligibility_result)
  end

  def unidentified?
    !!issue.unidentified
  end

  def nonrating?
    !!issue.prior_non_rating_decision_id
  end

  def rating?
    !!issue.prior_rating_decision_id
  end

  def rating_decision?
    !!issue.prior_decision_rating_disability_sequence_number
  end

  def decision_issue?
    !!issue.associated_caseflow_decision_id
  end

  def determine_benefit_type
    decision_review_created.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end

  def determine_pending_claim_review_type
    rating? ? duplicate_of_rating_issue_in_active_review : duplicate_of_nonrating_issue_in_active_review
  end

  def determine_time_restriction_type
    decision_date_before_ama? ? before_ama : untimely
  end

  def completed_claim_review?
    COMPLETED_REVIEW.include?(issue.eligibility_result)
  end

  def determine_completed_claim_review_type
    completed_board? ? appeal_to_higher_level_review : higher_level_review_to_higher_level_review
  end

  def contention_id_present?
    !!issue.contention_id
  end

  def handle_contention_id_present
    fail AppealsConsumer::Error::NotNullContentionIdError, "DecisionReviewCreated Claim ID"\
    " #{decision_review_created.claim_id} - Issue index #{index} is ineligible but has a not-null contention_id value"
  end

  def handle_unrecognized_eligibility_result
    fail AppealsConsumer::Error::IssueEligibilityResultNotRecognized, "DecisionReviewCreated Claim ID"\
    " #{decision_review_created.claim_id} - Issue index #{index} does not have a recognizable eligibility result"
  end

  def handle_missing_contention_id
    fail AppealsConsumer::Error::NullContentionIdError, "DecisionReviewCreated Claim ID"\
    " #{decision_review_created.claim_id} - Issue index #{index} has a null contention_id"
  end

  def handle_missing_notification_date
    fail AppealsConsumer::Error::NullPriorDecisionNotificationDate, "DecisionReviewCreated Claim ID"\
    " #{decision_review_created.claim_id} - Issue index #{index} has a null prior_decision_notification_date"
  end
end
