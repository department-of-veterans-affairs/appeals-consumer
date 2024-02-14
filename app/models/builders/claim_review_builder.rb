# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewCreated
class Builders::ClaimReviewBuilder
  attr_reader :claim_review, :decision_review_created

  PENSION_IDENTIFIER = "PMC"
  FILED_BY_VA_GOV = false
  COMPENSATION_BENEFIT_TYPE = "compensation"
  PENSION_BENEFIT_TYPE = "pension"

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.claim_review
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @claim_review = ClaimReview.new
  end

  def assign_attributes
    calculate_benefit_type
    assign_filed_by_va_gov
    assign_receipt_date
    calculate_legacy_opt_in_approved
    calculate_veteran_is_not_claimant
    assign_establishment_attempted_at
    assign_establishment_last_submitted_at
    assign_establishment_processed_at
    assign_establishment_submitted_at
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

  def assign_receipt_date
    @claim_review.receipt_date = decision_review_created.claim_received_date
  end

  def calculate_legacy_opt_in_approved
    @claim_review.legacy_opt_in_approved = any_opted_in_issues?
  end

  def calculate_veteran_is_not_claimant
    @claim_review.veteran_is_not_claimant = veteran_and_claimant_participant_ids_different?
  end

  def assign_establishment_attempted_at
    @claim_review.establishment_attempted_at = decision_review_created.claim_creation_time
  end

  def assign_establishment_last_submitted_at
    @claim_review.establishment_last_submitted_at = decision_review_created.claim_creation_time
  end

  def assign_establishment_processed_at
    @claim_review.establishment_processed_at = decision_review_created.claim_creation_time
  end

  def assign_establishment_submitted_at
    @claim_review.establishment_submitted_at = decision_review_created.claim_creation_time
  end

  def assign_informal_conference
    @claim_review.informal_conference = decision_review_created.informal_conference_requested
  end

  def assign_same_office
    @claim_review.same_office = decision_review_created.same_station_review_requested
  end

  def determine_benefit_type
    decision_review_created.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end

  def any_opted_in_issues?
    decision_review_created.decision_review_issues.any? { |issue| !!issue.soc_opt_in }
  end

  def veteran_and_claimant_participant_ids_different?
    decision_review_created.veteran_participant_id != decision_review_created.claimant_participant_id
  end
end
