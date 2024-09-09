# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewUpdated
class Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder < Builders::BaseEndProductEstablishmentBuilder
  def initialize(decision_review_model)
    super
    @end_product_establishment = DecisionReviewUpdated::EndProductEstablishment.new
  end

  def assign_attributes
    assign_decision_review_updated_development_item_reference_id
    assign_decision_review_updated_reference_id
    calculate_synced_status
    calculate_last_synced_at
    self
  end

  private

  def assign_decision_review_updated_development_item_reference_id
    @end_product_establishment.development_item_reference_id =
      @decision_review_model.informal_conference_tracked_item_id
  end

  def assign_decision_review_updated_reference_id
    @end_product_establishment.reference_id = @decision_review_model.claim_id.to_s
  end

  def calculate_last_synced_at
    @end_product_establishment.last_synced_at = claim_update_time_converted_to_timestamp_ms
  end
end
