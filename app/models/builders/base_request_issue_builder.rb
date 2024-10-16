# frozen_string_literal: true

class Builders::BaseRequestIssueBuilder # rubocop:disable Metrics/ClassLength
  include DecisionReview::ModelBuilderHelper

  # returns the DecisionReview model's RequestIssue record with all attributes assigned
  def self.build(issue, decision_review_model, bis_rating_profiles)
    builder = new(issue, decision_review_model, bis_rating_profiles)
    builder.assign_attributes
    builder.request_issue
  end

  def initialize(issue, decision_review_model, bis_rating_profiles, request_issue)
    @decision_review_model = decision_review_model
    @issue = issue
    @bis_rating_profiles = bis_rating_profiles
    @request_issue = request_issue
  end

  REQUEST_ISSUE = "RequestIssue"
  NONRATING_EP_CODE_CATEGORY = "NON_RATING"

  # the date AMA was launched
  # used to determine if "TIME_RESTRICTION" eligibility_result matches "before_ama" or "untimely" ineligible_reason
  AMA_ACTIVATION_DATE = Date.new(2019, 2, 19)

  # eligibility_result values that have a 1-to-1 match to a Request Issue ineligible_reason
  TIME_RESTRICTION = "TIME_RESTRICTION"
  COMPLETED_HLR = "COMPLETED_HLR"
  COMPLETED_BOARD_APPEAL = "COMPLETED_BOARD_APPEAL"
  PENDING_LEGACY_APPEAL = "PENDING_LEGACY_APPEAL"
  CONTESTED = "CONTESTED"

  # eligibility_result values grouped by Request Issue ineligible_reason
  COMPLETED_REVIEW = %w[COMPLETED_BOARD_APPEAL COMPLETED_HLR].freeze
  PENDING_REVIEW = %w[PENDING_HLR PENDING_BOARD_APPEAL PENDING_SUPPLEMENTAL].freeze
  LEGACY_APPEAL_NOT_ELIGIBLE = %w[LEGACY_TIME_RESTRICTION NO_SOC_SSOC].freeze

  # eligibility_result values grouped by ineligible and eligible
  ELIGIBLE = %w[ELIGIBLE ELIGIBLE_LEGACY].freeze
  INELIGIBLE = %w[
    TIME_RESTRICTION PENDING_LEGACY_APPEAL LEGACY_TIME_RESTRICTION NO_SOC_SSOC CONTESTED
    PENDING_HLR COMPLETED_HLR PENDING_BOARD_APPEAL COMPLETED_BOARD_APPEAL PENDING_SUPPLEMENTAL
  ].freeze

  CLOSED_STATUSES = {
    ineligible_closed_status: "ineligible",
    removed_closed_status: "removed",
    withdrawn_closed_status: "withdrawn"
  }.freeze

  INELIGIBLE_REASONS = {
    duplicate_of_nonrating_issue_in_active_review: "duplicate_of_nonrating_issue_in_active_review",
    duplicate_of_rating_issue_in_active_review: "duplicate_of_rating_issue_in_active_review",
    untimely: "untimely",
    higher_level_review_to_higher_level_review: "higher_level_review_to_higher_level_review",
    appeal_to_higher_level_review: "appeal_to_higher_level_review",
    before_ama: "before_ama",
    legacy_issue_not_withdrawn: "legacy_issue_not_withdrawn",
    legacy_appeal_not_eligible: "legacy_appeal_not_eligible",
    contested: "contested"
  }.freeze

  # used to determine ramp_claim_id
  RAMP_EP_CODES = {
    "682HLRRRAMP" => "Higher-Level Review Rating",
    "683SCRRRAMP" => "Supplemental Claim Review Rating",
    "683HAERRAMP" => "Higher-Level Review Additional Evidence Rating"
  }.freeze

  # -- Methods

  def assign_attributes
    assign_methods
    calculate_methods
  end

  private

  def assign_methods
    assign_contested_rating_decision_reference_id
    assign_contested_rating_issue_reference_id
    assign_contested_decision_issue_id
    assign_untimely_exemption
    assign_untimely_exemption_notes
    assign_vacols_id
    assign_vacols_sequence_id
    assign_nonrating_issue_bgs_id
    assign_type
    assign_decision_review_issue_id
    assign_veteran_participant_id
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
    calculate_rating_issue_associated_at
    calculate_ramp_claim_id
    calculate_is_unidentified
    calculate_nonrating_issue_bgs_source
  end

  # EP codes ending in "PMC" are pension, otherwise "compensation"
  def calculate_benefit_type
    @request_issue.benefit_type = determine_benefit_type
  end

  # only rating issues, rating decisions, and issues with an associated decision issue populate this field
  def calculate_contested_issue_description
    @request_issue.contested_issue_description =
      rating_or_decision_issue? ? remove_duplicate_prior_decision_type_text : nil
  end

  # eligible issues should always have a contention_id
  def calculate_contention_reference_id
    if eligible? && contention_id_not_present?
      handle_missing_contention_id
    end

    @request_issue.contention_reference_id = issue.contention_id.presence
  end

  # represents "disSn" from the issue's BIS rating profile. Needed for backfill issues
  def assign_contested_rating_decision_reference_id
    @request_issue.contested_rating_decision_reference_id = issue.prior_decision_rating_sn&.to_s
  end

  # only populate if issue is a rating issue
  def calculate_contested_rating_issue_profile_date
    @request_issue.contested_rating_issue_profile_date = rating? ? issue.prior_decision_rating_profile_date : nil
  end

  def assign_contested_rating_issue_reference_id
    @request_issue.contested_rating_issue_reference_id = issue.prior_rating_decision_id&.to_s
  end

  # both rating and nonrating issues can be associated to a caseflow decision_issue
  def assign_contested_decision_issue_id
    @request_issue.contested_decision_issue_id = issue.prior_caseflow_decision_issue_id
  end

  # only unidentified issues can have an optional user-input decision date
  # if an identified issue does not have a decision date, the error is logged
  # and current in progress EventAudit notes are updated with error
  def calculate_decision_date
    begin
      handle_missing_decision_date if prior_decision_date_not_present? && identified?
    rescue AppealsConsumer::Error::NullPriorDecisionDate => error
      error_name_and_msg = "#{error.class.name}-#{error}"
      log_msg_and_update_current_event_audit_notes!(error_name_and_msg, error: true)
    end

    @request_issue.decision_date = prior_decision_date_converted_to_logical_type
  end

  # if the issue's eligibility_result is "PENDING_BOARD_APPEAL", "PENDING_HLR", or "PENDING_SUPPLEMENTAL"
  # there must be an associated_caseflow_request_issue_id to correlate the pre-existing request issue to
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

  # caseflow expects unidentified issues to be rating
  # if the issue is nonrating, assign to 'false'
  def calculate_is_unidentified
    @request_issue.is_unidentified = nonrating_ep_code? ? false : unidentified?
  end

  # only populate if issue is unidentified rating
  def calculate_unidentified_issue_text
    @request_issue.unidentified_issue_text =  (unidentified? && !nonrating_ep_code?) ? issue.prior_decision_text : nil
  end

  # always populate if ep_code_category is "NON-RATING"
  def calculate_nonrating_issue_category
    @request_issue.nonrating_issue_category = nonrating_ep_code? ? issue.prior_decision_type : nil
  end

  # only populate for issues that are nonrating and do not have an associated caseflow decision issue
  def calculate_nonrating_issue_description
    @request_issue.nonrating_issue_description =
      if nonrating_ep_code? && !decision_issue?
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

  # default initial state of "RequestIssue"
  def assign_type
    @request_issue.type = REQUEST_ISSUE
  end

  # must override method in child class
  def calculate_closed_at
    fail NotImplementedError, "#{self.class} must implement the #calculate_closed_at method"
  end

  # default state of ineligible issues - "ineligible"
  # DecisionReviewCreated events cannot have 'removed' or 'withdrawn' closed statuses
  def calculate_closed_status
    closed_status_value = nil
    if ineligible?
      closed_status_value = ineligible_closed_status
    elsif removed?
      closed_status_value = removed_closed_status
    elsif withdrawn?
      closed_status_value = withdrawn_closed_status
    end
    @request_issue.closed_status = closed_status_value
  end

  # only populated for rating and rating decision issues
  def calculate_contested_rating_issue_diagnostic_code
    @request_issue.contested_rating_issue_diagnostic_code =
      if rating_or_rating_decision?
        issue.prior_decision_diagnostic_code
      end
  end

  # only populated for rating issues
  # represents the claim_id of the RAMP EP connected to the rating issue
  def calculate_ramp_claim_id
    @request_issue.ramp_claim_id = rating? ? determine_ramp_claim_id : nil
  end

  # only populated for eligible rating issues
  def calculate_rating_issue_associated_at
    fail NotImplementedError, "#{self.class} must implement the #calculate_rating_issue_associated_at method"
  end

  def assign_nonrating_issue_bgs_id
    @request_issue.nonrating_issue_bgs_id = issue.prior_non_rating_decision_id&.to_s
  end

  def calculate_nonrating_issue_bgs_source
    @request_issue.nonrating_issue_bgs_source =
      if decision_review_model.ep_code_category == NONRATING_EP_CODE_CATEGORY
        issue.prior_decision_source&.to_s
      end
  end

  # exception thrown if an unrecognized eligibility_result is passed in
  # eligible issues always have NIL for ineligible_reason
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def determine_ineligible_reason
    if eligible?
      ineligible_reason_value = nil
    elsif pending_claim_review?
      ineligible_reason_value = determine_pending_claim_review_type
    elsif time_restriction?
      ineligible_reason_value = determine_time_restriction_type
    elsif completed_claim_review?
      ineligible_reason_value = determine_completed_claim_review_type
    elsif pending_legacy_appeal?
      ineligible_reason_value = legacy_issue_not_withdrawn
    elsif legacy_time_restriction_or_no_soc_ssoc?
      ineligible_reason_value = legacy_appeal_not_eligible
    elsif contested?
      ineligible_reason_value = contested
    else
      handle_unrecognized_eligibility_result
    end
    ineligible_reason_value
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def ineligible_closed_status
    CLOSED_STATUSES[:ineligible_closed_status]
  end

  def removed_closed_status
    CLOSED_STATUSES[:removed_closed_status]
  end

  def withdrawn_closed_status
    CLOSED_STATUSES[:withdrawn_closed_status]
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

  def contested
    INELIGIBLE_REASONS[:contested]
  end

  def handle_associated_request_issue_not_present
    unless associated_caseflow_request_issue_present?
      message = "Issue with contention id of #{issue.contention_id} is ineligible due"\
        " to a pending review but has null for associated_caseflow_request_issue_id"
      log_msg_and_update_current_event_audit_notes!(message, error: false)
    end
  end

  # removes duplicate prior_decision_type text from prior_decision_text field
  # example:
  # prior_decision_type: "DIC"
  # prior_decision_text: "DIC: Service connection for tetnus denied"
  # final result: "Service connection for tetnus denied"
  def remove_duplicate_prior_decision_type_text
    category = issue.prior_decision_type
    return issue.prior_decision_text unless category

    category += ": "
    description = issue.prior_decision_text

    description.gsub(/^#{Regexp.escape(category)}/i, "")
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

  def contested?
    issue.eligibility_result == CONTESTED
  end

  def completed_board_appeal?
    issue.eligibility_result == COMPLETED_BOARD_APPEAL
  end

  def associated_caseflow_request_issue_present?
    !!issue.associated_caseflow_request_issue_id
  end

  # an issue can contest a rating issue, rating decision, or nonrating issue
  def identified?
    rating? || rating_decision? || nonrating?
  end

  def prior_decision_date_not_present?
    !issue.prior_decision_date
  end

  def contention_id_not_present?
    !issue.contention_id
  end

  def ineligible?
    INELIGIBLE.include?(issue.eligibility_result)
  end

  # Checks if issue has been removed on a Decision Review event
  # DecisionReviewCreated events do not have a 'removed' attribute
  def removed?
    issue.try(:removed) == true
  end

  # Checks if issue has been removed on a Decision Review event
  # DecisionReviewCreated events do not have a 'withdrawn' attribute
  def withdrawn?
    issue.try(:withdrawn) == true
  end

  def eligible?
    ELIGIBLE.include?(issue.eligibility_result)
  end

  def rating_or_rating_decision?
    rating? || rating_decision?
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
    !!issue.prior_decision_rating_sn
  end

  def decision_issue?
    !!issue.prior_caseflow_decision_issue_id
  end

  def nonrating_ep_code?
    !!(decision_review_model.ep_code_category.upcase == NONRATING_EP_CODE_CATEGORY)
  end

  def edited_description?
    prior_decision_text_changed? && updated_contention?
  end

  def prior_decision_text_changed?
    issue.try(:reason_for_contention_action) == "PRIOR_DECISION_TEXT_CHANGED"
  end

  def updated_contention?
    issue.try(:contention_action) == "UPDATE_CONTENTION"
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
    completed_board_appeal? ? appeal_to_higher_level_review : higher_level_review_to_higher_level_review
  end

  def contention_id_present?
    !!issue.contention_id
  end

  def prior_decision_date_converted_to_logical_type
    convert_to_date_logical_type(issue.prior_decision_date)
  end

  # fetch rating profile from BIS and find the clm_id of the RAMP ep, if one exists
  def determine_ramp_claim_id
    return nil unless @bis_rating_profiles && associated_claims_data

    associated_ramp_ep = find_associated_ramp_ep(associated_claims_data)
    associated_ramp_ep&.dig(:clm_id)
  end

  # parses response to find all claim data, then finds claims that associate with this issue
  def associated_claims_data
    all_claims = find_all_claims
    return nil if all_claims.nil?

    find_associated_claims(all_claims)
  end

  def find_all_claims
    @bis_rating_profiles.extend Hashie::Extensions::DeepFind
    claims = @bis_rating_profiles&.deep_find_all(:rba_claim)
    return if claims.nil? || claims.all?(&:nil?)

    claims.flatten
  end

  def find_associated_claims(all_claims)
    matching_claims = all_claims.select do |claim|
      claim_profile_date_matches_issue_profile_date?(claim)
    end

    matching_claims.presence
  end

  # finds matching claims by comparing profile date of the claim with the issue's profile date
  def claim_profile_date_matches_issue_profile_date?(claim)
    return unless claim&.dig(:prfl_date) && issue.prior_decision_rating_profile_date

    claim&.dig(:prfl_date)&.to_date == issue.prior_decision_rating_profile_date.to_date
  end

  # return the first associated_claim that has a RAMP ep code. if there aren't any that match return nil
  def find_associated_ramp_ep(associated_claims_data)
    associated_claims_data.find do |claim|
      ep_code = claim&.dig(:bnft_clm_tc)

      RAMP_EP_CODES.key?(ep_code)
    end
  end

  def handle_unrecognized_eligibility_result
    fail AppealsConsumer::Error::IssueEligibilityResultNotRecognized, "Issue has an unrecognized eligibility_result:"\
      " #{issue.eligibility_result}"
  end

  def handle_missing_contention_id
    fail AppealsConsumer::Error::NullContentionIdError, "Issue is eligible but has null for contention_id"
  end

  def handle_missing_decision_date
    msg = "Issue with contention_id #{issue.contention_id} is identified but has null for prior_decision_date"
    fail AppealsConsumer::Error::NullPriorDecisionDate, msg
  end

  # used to determine if "TIME_RESTRICTION" eligibility_result maps to "untimely" or "before_ama" ineligible_reason
  def decision_date_before_ama?
    decision_date = prior_decision_date_converted_to_logical_type

    if decision_date
      ama_activation_date_logical_type = (AMA_ACTIVATION_DATE - EPOCH_DATE).to_i
      decision_date < ama_activation_date_logical_type
    end
  end

  def determine_benefit_type
    decision_review_model.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end

  def assign_decision_review_issue_id
    @request_issue.decision_review_issue_id = issue.decision_review_issue_id
  end

  def assign_veteran_participant_id
    @request_issue.veteran_participant_id = decision_review_model.veteran_participant_id
  end
end
