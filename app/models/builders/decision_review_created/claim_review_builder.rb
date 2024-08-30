# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::ClaimReviewBuilder
  include DecisionReview::ModelBuilderHelper
  attr_reader :claim_review, :decision_review_model

  FILED_BY_VA_GOV = nil

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.assign_attributes
    builder.claim_review
  end

  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
    @claim_review = DecisionReviewCreated::ClaimReview.new
  end

  def assign_attributes
    calculate_benefit_type
    assign_filed_by_va_gov
    calculate_receipt_date
    calculate_legacy_opt_in_approved
    calculate_veteran_is_not_claimant
    calculate_establishment_attempted_at
    calculate_establishment_last_submitted_at
    calculate_establishment_processed_at
    calculate_establishment_submitted_at
    assign_informal_conference
    assign_same_office
  end

  private

  def calculate_benefit_type
    @claim_review.benefit_type = determine_benefit_type
  end

  def assign_filed_by_va_gov
    @claim_review.filed_by_va_gov = FILED_BY_VA_GOV
  end

  def calculate_receipt_date
    @claim_review.receipt_date = convert_to_date_logical_type(decision_review_model.claim_received_date)
  end

  def calculate_legacy_opt_in_approved
    @claim_review.legacy_opt_in_approved = any_opted_in_issues?
  end

  def calculate_veteran_is_not_claimant
    @claim_review.veteran_is_not_claimant = veteran_and_claimant_participant_ids_different?
  end

  def calculate_establishment_attempted_at
    @claim_review.establishment_attempted_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_establishment_last_submitted_at
    @claim_review.establishment_last_submitted_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_establishment_processed_at
    @claim_review.establishment_processed_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_establishment_submitted_at
    @claim_review.establishment_submitted_at = claim_creation_time_converted_to_timestamp_ms
  end

  def assign_informal_conference
    @claim_review.informal_conference = decision_review_model.informal_conference_requested
  end

  def assign_same_office
    @claim_review.same_office = decision_review_model.same_station_review_requested
  end

  def determine_benefit_type
    decision_review_model.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end

  def any_opted_in_issues?
    decision_review_model.decision_review_issues.any? { |issue| !!issue.soc_opt_in }
  end

  def veteran_and_claimant_participant_ids_different?
    decision_review_model.veteran_participant_id != decision_review_model.claimant_participant_id
  end
end
