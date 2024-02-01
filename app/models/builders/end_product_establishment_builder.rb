# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewCreated
class Builders::EndProductEstablishmentBuilder
  attr_reader :end_product_establishment

  def self.build(decision_review_created)
    builder = new
    builder.assign_attributes(decision_review_created)
    builder.end_product_establishment
  end

  def initialize
    @end_product_establishment = EndProductEstablishment.new
  end

  def assign_attributes(decision_review_created)
    calculate_benefit_type_code(decision_review_created)
    assign_claim_date(decision_review_created)
    assign_code(decision_review_created)
    assign_modifier(decision_review_created)
    assign_payee_code(decision_review_created)
    calculate_limited_poa_access(decision_review_created)
    calculate_limited_poa_code(decision_review_created)
    calculate_committed_at(decision_review_created)
    calculate_established_at(decision_review_created)
    calculate_last_synced_at(decision_review_created)
    assign_synced_status(decision_review_created)
    assign_development_item_reference_id(decision_review_created)
    assign_reference_id(decision_review_created)
  end

  private

  def calculate_benefit_type_code(decision_review_created); end

  def assign_claim_date(decision_review_created); end

  def assign_code(decision_review_created); end

  def assign_modifier(decision_review_created); end

  def assign_payee_code(decision_review_created); end

  def calculate_limited_poa_access(decision_review_created); end

  def calculate_limited_poa_code(decision_review_created); end

  def calculate_committed_at(decision_review_created); end

  def calculate_established_at(decision_review_created); end

  def calculate_last_synced_at(decision_review_created); end

  def assign_synced_status(decision_review_created); end

  def assign_development_item_reference_id(decision_review_created); end

  def assign_reference_id(decision_review_created); end
end
