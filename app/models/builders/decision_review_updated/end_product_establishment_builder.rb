# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewUpdated
class Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder
  attr_reader :end_product_establishment, :decision_review_updated

  def self.build(decision_review_updated)
    builder = new(decision_review_updated)
    builder.assign_attributes
    builder.end_product_establishment
  end

  def initialize(decision_review_updated)
    @decision_review_updated = decision_review_updated
    @end_product_establishment = DecisionReviewUpdated::EndProductEstablishment.new
  end

  def assign_attributes
    assign_decision_review_updated_development_item_reference_id
    assign_decision_review_updated_reference_id
    self
  end

  private

  def assign_decision_review_updated_development_item_reference_id
    @end_product_establishment.development_item_reference_id =
      @decision_review_updated.informal_conference_tracked_item_id
  end

  def assign_decision_review_updated_reference_id
    @end_product_establishment.reference_id = @decision_review_updated.claim_id.to_s
  end
end
