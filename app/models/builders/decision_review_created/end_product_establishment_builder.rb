# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::EndProductEstablishmentBuilder < Builders::BaseEndProductEstablishmentBuilder
  def initialize(decision_review_model)
    super
    @end_product_establishment = DecisionReviewCreated::EndProductEstablishment.new
    @veteran_bis_record = fetch_veteran_bis_record
    @limited_poa_hash = fetch_limited_poa
  end

  private

  def calculate_committed_at
    @end_product_establishment.committed_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_established_at
    @end_product_establishment.established_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_last_synced_at
    @end_product_establishment.last_synced_at = claim_creation_time_converted_to_timestamp_ms
  end
end
