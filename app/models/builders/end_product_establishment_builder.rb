# frozen_string_literal: true

# This class is used to build out an End Product Establishment object from an instance of DecisionReviewCreated
class Builders::EndProductEstablishmentBuilder
  include ModelBuilder
  attr_reader :end_product_establishment, :decision_review_created

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.end_product_establishment
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @end_product_establishment = EndProductEstablishment.new
    @veteran_bis_record = fetch_veteran_bis_record
    @limited_poa_hash = fetch_limited_poa
  end

  # :reek:TooManyStatements
  def assign_attributes
    calculate_benefit_type_code
    assign_claim_date
    assign_code
    assign_modifier
    assign_payee_code
    calculate_limited_poa_access
    calculate_limited_poa_code
    assign_committed_at
    assign_established_at
    assign_last_synced_at
    assign_synced_status
    assign_development_item_reference_id
    assign_reference_id
    self
  end

  private

  def calculate_benefit_type_code
    @end_product_establishment.benefit_type_code = @veteran_bis_record[:date_of_death].nil? ? "1" : "2"
  end

  def assign_claim_date
    @end_product_establishment.claim_date = @decision_review_created.claim_received_date
  end

  def assign_code
    @end_product_establishment.code = @decision_review_created.ep_code
  end

  def assign_modifier
    @end_product_establishment.modifier = @decision_review_created.modifier
  end

  def assign_payee_code
    @end_product_establishment.payee_code = @decision_review_created.payee_code
  end

  def calculate_limited_poa_access
    @end_product_establishment.limited_poa_access =
      if limited_poa_access == "Y"
        true
      elsif limited_poa_access == "N"
        false
      end
  end

  def calculate_limited_poa_code
    @end_product_establishment.limited_poa_code = @limited_poa_hash&.dig(:limited_poa_code)
  end

  def assign_committed_at
    @end_product_establishment.committed_at = @decision_review_created.claim_creation_time
  end

  def assign_established_at
    @end_product_establishment.established_at = @decision_review_created.claim_creation_time
  end

  def assign_last_synced_at
    @end_product_establishment.last_synced_at = @decision_review_created.claim_creation_time
  end

  def assign_synced_status
    @end_product_establishment.synced_status = @decision_review_created.claim_lifecycle_status
  end

  def assign_development_item_reference_id
    @end_product_establishment.development_item_reference_id =
      @decision_review_created.informal_conference_tracked_item_id.to_s
  end

  def assign_reference_id
    @end_product_establishment.reference_id = @decision_review_created.claim_id.to_s
  end

  def limited_poa_access
    @limited_poa_hash&.dig(:limited_poa_access)
  end
end
