# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewCreated
class Builders::EndProductEstablishmentBuilder
  attr_reader :end_product_establishment, :decision_review_created

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.end_product_establishment
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @end_product_establishment = EndProductEstablishment.new
  end

  def assign_attributes
    calculate_benefit_type_code
    assign_claim_date
    assign_code
    assign_modifier
    assign_payee_code
    calculate_limited_poa_access
    calculate_limited_poa_code
    calculate_committed_at
    calculate_established_at
    calculate_last_synced_at
    assign_synced_status
    assign_development_item_reference_id
    assign_reference_id
  end

  private

  def calculate_benefit_type_code; end

  def assign_claim_date; end

  def assign_code; end

  def assign_modifier; end

  def assign_payee_code; end

  def calculate_limited_poa_access; end

  def calculate_limited_poa_code; end

  def calculate_committed_at; end

  def calculate_established_at; end

  def calculate_last_synced_at; end

  def assign_synced_status; end

  def assign_development_item_reference_id; end

  def assign_reference_id; end
end
