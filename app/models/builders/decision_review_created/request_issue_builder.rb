# frozen_string_literal: true

# This class is used to build out an individual Request Issue from decision_review_created.decision_review_issues
class Builders::DecisionReviewCreated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  include DecisionReview::ModelBuilder
  attr_reader :decision_review_created, :issue, :request_issue

  # returns the DecisionReviewCreated::RequestIssue record with all attributes assigned
  def self.build(issue, decision_review_created, bis_rating_profiles)
    builder = new(issue, decision_review_created, bis_rating_profiles)
    builder.assign_attributes
    builder.request_issue
  end

  def initialize(issue, decision_review_created, bis_rating_profiles)
    @decision_review_created = decision_review_created
    @issue = issue
    @bis_rating_profiles = bis_rating_profiles
    @request_issue = DecisionReviewCreated::RequestIssue.new
    super()
  end

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

  ## THESE ONES DON'T PASS WHEN MIGRATED TO BASE
  ## ===========================================

  # used to determine if "TIME_RESTRICTION" eligibility_result maps to "untimely" or "before_ama" ineligible_reason
  def decision_date_before_ama?
    decision_date = prior_decision_date_converted_to_logical_type

    if decision_date
      ama_activation_date_logical_type = (AMA_ACTIVATION_DATE - EPOCH_DATE).to_i
      decision_date < ama_activation_date_logical_type
    end
  end

  def determine_benefit_type
    decision_review_created.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end

  ## ==========================================

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

  def handle_contention_id_present
    fail AppealsConsumer::Error::NotNullContentionIdError,
         "Issue is ineligible but has a not-null contention_id value"
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
end
