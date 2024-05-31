# frozen_string_literal: true

class Builders::DecisionReviewCompleted::EndProductEstablishmentBuilder
  include DecisionReviewCompleted::ModelBuilder
  attr_reader :end_product_establishment, :decision_review_completed

  def self.build(decision_review_completed)
    builder = new(decision_review_completed)
    builder.assign_attributes
    builder.end_product_establishment
  end

  def initialize(decision_review_completed)
    @decision_review_completed= decision_review_completed
    @end_product_establishment = DecisionReviewCompleted::EndProductEstablishment.new
  end

  def assign_attributes
    calculate_synced_status
    calculate_last_synced_at
    assign_reference_id
    assign_code
  end

  def calculate_synced_status
  end

  def calculate_last_synced_at
  end

  def assign_reference_id
  end

  def assign_code
  end

end