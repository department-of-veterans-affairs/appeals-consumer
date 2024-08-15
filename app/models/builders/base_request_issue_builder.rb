# frozen_string_literal: true

class Builders::BaseRequestIssueBuilder
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

  # eligibility_result values grouped by Request Issue ineligible_reason
  COMPLETED_REVIEW = %w[COMPLETED_BOARD_APPEAL COMPLETED_HLR].freeze
  PENDING_REVIEW = %w[PENDING_HLR PENDING_BOARD_APPEAL PENDING_SUPPLEMENTAL].freeze
  LEGACY_APPEAL_NOT_ELIGIBLE = %w[LEGACY_TIME_RESTRICTION NO_SOC_SSOC].freeze

  # eligibility_result values grouped by ineligible and eligible
  ELIGIBLE = %w[ELIGIBLE ELIGIBLE_LEGACY].freeze
  INELIGIBLE = %w[
    TIME_RESTRICTION PENDING_LEGACY_APPEAL LEGACY_TIME_RESTRICTION NO_SOC_SSOC
    PENDING_HLR COMPLETED_HLR PENDING_BOARD_APPEAL COMPLETED_BOARD_APPEAL PENDING_SUPPLEMENTAL
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

  # used to determine ramp_claim_id
  RAMP_EP_CODES = {
    "682HLRRRAMP" => "Higher-Level Review Rating",
    "683SCRRRAMP" => "Supplemental Claim Review Rating",
    "683HAERRAMP" => "Higher-Level Review Additional Evidence Rating"
  }.freeze

  # EP codes ending in "PMC" are pension, otherwise "compensation"
  def calculate_benefit_type
    @request_issue.benefit_type = determine_benefit_type
  end

  # only rating issues, rating decisions, and issues with an associated decision issue populate this field
  def calculate_contested_issue_description
    @request_issue.contested_issue_description =
      rating_or_decision_issue? ? remove_duplicate_prior_decision_type_text : nil
  end

  # eligible issues should always have a not-nil contention_id
  # ineligible issues should never have a nil contention_id
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
  ## ----------------------------------------------------
  ## Test still pass after migrating the methods above from request_issue_builder.rb
  ## ----------------------------------------------------
end
