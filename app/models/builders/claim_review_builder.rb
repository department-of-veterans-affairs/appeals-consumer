# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewCreated
class Builders::ClaimReviewBuilder
  attr_reader :claim_review, :decision_review_created

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
    assign_legacy_opt_in_approved
    calculate_veteran_is_not_claimant
    calculate_establishment_attempted_at
    calculate_establishment_last_submitted_at
    calculate_establishment_processed_at
    calculate_establishment_submitted_at
    assign_informal_conference
    assign_same_office
  end

  private

  def calculate_benefit_type; end

  # always false
  def assign_filed_by_va_gov; end

  def assign_receipt_date; end

  def assign_legacy_opt_in_approved; end

  def calculate_veteran_is_not_claimant; end

  def calculate_establishment_attempted_at; end

  def calculate_establishment_last_submitted_at; end

  def calculate_establishment_processed_at; end

  def calculate_establishment_submitted_at; end

  def assign_informal_conference; end

  def assign_same_office; end
end
