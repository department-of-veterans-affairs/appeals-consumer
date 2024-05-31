# frozen_string_literal: true

class Builders::DecisionReviewCompleted::ClaimReviewBuilder
  include DecisionReviewCompleted::ModelBuilder
  attr_reader :end_product_establishment, :decision_review_completed

  def self.build(decision_review_completed)
    builder = new(decision_review_completed)
    builder.assign_attributes
    builder.claim_review
  end

  def assign_attributes
    calculate_establishment_canceled_at
    calculate_establishment_processed_at
  end

  private

  def calculate_establishment_canceled_at
  end

  def calculate_establishment_processed_at
  end
end