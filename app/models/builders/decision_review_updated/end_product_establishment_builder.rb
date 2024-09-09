# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewUpdated
class Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder < Builders::BaseEndProductEstablishmentBuilder
  def initialize(decision_review_model)
    super
    @end_product_establishment = DecisionReviewUpdated::EndProductEstablishment.new
  end

  def assign_attributes
    assign_development_item_reference_id
    assign_reference_id
    calculate_synced_status
    calculate_last_synced_at
    self
  end

  private

  def calculate_last_synced_at
    @end_product_establishment.last_synced_at = claim_update_time_converted_to_timestamp_ms
  end
end
