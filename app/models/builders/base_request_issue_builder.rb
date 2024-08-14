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
end
