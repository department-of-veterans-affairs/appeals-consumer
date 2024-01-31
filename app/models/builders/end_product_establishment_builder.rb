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
    assign_claim_date(decision_review_created)
    assign_code(decision_review_created)
    assign_modifier(decision_review_created)
    assign_reference_id(decision_review_created)
  end

  private

  def assign_claim_date(decision_review_created); end

  def assign_code(decision_review_created); end

  def assign_modifier(decision_review_created); end

  def assign_reference_id(decision_review_created); end
end
