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

  # ineligible issues are closed upon creation
  def calculate_closed_at
    @request_issue.closed_at = ineligible? ? claim_creation_time_converted_to_timestamp_ms : nil
  end

  # default state of ineligible issues - "ineligible"
  def calculate_closed_status
    @request_issue.closed_status = ineligible? ? INELIGIBLE_CLOSED_STATUS : nil
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
    @request_issue.rating_issue_associated_at =
      if rating? && eligible?
        claim_creation_time_converted_to_timestamp_ms
      end
  end

  def assign_nonrating_issue_bgs_id
    @request_issue.nonrating_issue_bgs_id = issue.prior_non_rating_decision_id&.to_s
  end

  def calculate_nonrating_issue_bgs_source
    @request_issue.nonrating_issue_bgs_source =
      if decision_review_created.ep_code_category == NONRATING_EP_CODE_CATEGORY
        issue.prior_decision_source&.to_s
      end
  end

  ## ----------------------------------------------------
  ## Test still pass after migrating the methods above from request_issue_builder.rb
  ## ----------------------------------------------------
end