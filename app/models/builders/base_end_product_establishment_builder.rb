# frozen_string_literal: true

class Builders::BaseEndProductEstablishmentBuilder
  include DecisionReview::ModelBuilderHelper
  attr_reader :end_product_establishment, :decision_review_model

  CODES = {
    OPEN: "PEND",
    READY_TO_WORK: "RW",
    READY_FOR_DECISION: "RFD",
    SECONDARY_READY_FOR_DECISION: "SRFD",
    RATING_CORRECTION: "RC",
    RATING_INCOMPLETE: "RI",
    RATING_DECISION_COMPLETE: "RDC",
    RETURNED_BY_OTHER_USER: "RETOTH",
    SELF_RETURNED: "SELFRET",
    PENDING_AUTHORIZATION: "PENDAUTH",
    PENDING_CONCUR: "PENDCONC",
    AUTHORIZED: "AUTH",
    CANCELLED: "CAN",
    CLOSED: "CLOSED"
  }.freeze

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.assign_attributes
    builder.end_product_establishment
  end

  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
  end

  # :reek:TooManyStatements
  def assign_attributes
    calculate_benefit_type_code
    calculate_claim_date
    assign_code
    assign_modifier
    assign_payee_code
    calculate_limited_poa_access
    calculate_limited_poa_code
    calculate_committed_at
    calculate_established_at
    calculate_last_synced_at
    calculate_synced_status
    determine_synced_status
    assign_development_item_reference_id
    assign_reference_id
    self
  end

  private

  def calculate_benefit_type_code
    @end_product_establishment.benefit_type_code = determine_date_of_death
  end

  def calculate_claim_date
    @end_product_establishment.claim_date = convert_to_date_logical_type(@decision_review_model.claim_received_date)
  end

  def assign_code
    @end_product_establishment.code = @decision_review_model.ep_code
  end

  def assign_modifier
    @end_product_establishment.modifier = @decision_review_model.modifier
  end

  def assign_payee_code
    @end_product_establishment.payee_code = @decision_review_model.payee_code
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
    @limited_poa_hash.extend Hashie::Extensions::DeepFind
    poa_code = @limited_poa_hash.deep_find_all(:limited_poa_code)
    @end_product_establishment.limited_poa_code = poa_code.nil? ? nil : poa_code[0]
  end

  def calculate_last_synced_at
    fail NotImplementedError, "#{self.class} must implement the calculate_last_synced_at method"
  end

  def calculate_synced_status
    @end_product_establishment.synced_status = determine_synced_status
  end

  def determine_synced_status
    status = @decision_review_model.claim_lifecycle_status.upcase.tr(" ", "_")
    CODES[status.to_sym] || ""
  end

  def assign_development_item_reference_id
    @end_product_establishment.development_item_reference_id =
      @decision_review_model.informal_conference_tracked_item_id
  end

  def assign_reference_id
    @end_product_establishment.reference_id = @decision_review_model.claim_id.to_s
  end

  def limited_poa_access
    @limited_poa_hash.extend Hashie::Extensions::DeepFind
    limited_poa = @limited_poa_hash&.deep_find_all(:limited_poa_access)
    limited_poa.nil? ? nil : limited_poa[0]
  end

  def determine_date_of_death
    return nil unless @veteran_bis_record&.key?(:date_of_death)

    @veteran_bis_record&.dig(:date_of_death).nil? ? "1" : "2"
  end
end
