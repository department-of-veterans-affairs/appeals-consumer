# frozen_string_literal: true

# This class is ultimately responsible for constructing a DecisionReviewCreated payload
# that will be sent to Caseflow.
# :reek:TooManyInstanceVariables
# :reek:TooManyMethods
# :reek:InstanceVariableAssumption
class Builders::DecisionReviewCreated::DtoBuilder < Builders::BaseDtoBuilder
  attr_reader :payload

  def initialize(drc_event)
    MetricsService.record("Build decision review created #{drc_event}",
                          service: :dto_builder,
                          name: "Builders::DecisionReviewCreated::DtoBuilder.initialize") do
      super()
      @event_id = drc_event.id
      @decision_review_created = build_decision_review_created(drc_event.message_payload_hash)
      assign_attributes
    end
  end

  private

  # :reek:UtilityFunction
  def build_decision_review_created(message_payload)
    Transformers::DecisionReviewCreated.new(@event_id, message_payload)
  end

  # :reek:TooManyStatements
  def assign_attributes
    # assign_from_builders needs to be called first for other assign methods to fucntion properly
    assign_from_builders
    assign_from_decision_review_created
    assign_from_retrievals
    assign_payload
  end

  # :reek:TooManyStatements
  def assign_from_decision_review_created
    @auto_remand = @decision_review_created.auto_remand
    @claim_id = @decision_review_created.claim_id
    @css_id = @decision_review_created.actor_username
    @detail_type = @intake.detail_type
    @decision_review_created.decision_review_type
    @station = @decision_review_created.actor_station
    @vet_file_number = @decision_review_created.file_number
    @vet_first_name = @decision_review_created.veteran_first_name
    @vet_last_name = @decision_review_created.veteran_last_name
  end

  # :reek:TooManyStatements
  def assign_from_builders
    begin
      @intake = build_intake
      @veteran = build_veteran
      @claimant = build_claimant
      @claim_review = build_claim_review
      @end_product_establishment = build_end_product_establishment
      @request_issues = build_request_issues
    rescue StandardError => error
      raise AppealsConsumer::Error::DtoBuildError, "Failed building from Builders::DecisionReviewCreated::DtoBuilder:
        #{error.message}"
    end
  end

  def assign_payload
    @payload = validate_no_pii(build_payload)
  end

  def build_intake
    Builders::DecisionReviewCreated::IntakeBuilder.build(@decision_review_created)
  end

  def build_veteran
    Builders::DecisionReviewCreated::VeteranBuilder.build(@decision_review_created)
  end

  def build_claimant
    Builders::DecisionReviewCreated::ClaimantBuilder.build(@decision_review_created)
  end

  def build_claim_review
    Builders::DecisionReviewCreated::ClaimReviewBuilder.build(@decision_review_created)
  end

  def build_end_product_establishment
    Builders::DecisionReviewCreated::EndProductEstablishmentBuilder.build(@decision_review_created)
  end

  def build_request_issues
    Builders::DecisionReviewCreated::RequestIssueCollectionBuilder.build(@decision_review_created)
  end

  def build_payload
    {
      "auto_remand": @auto_remand,
      "event_id": @event_id,
      "claim_id": @claim_id,
      "css_id": @css_id,
      "detail_type": @detail_type,
      "station": @station,
      "intake": clean_pii(@intake),
      "veteran": clean_pii(@veteran),
      "claimant": clean_pii(@claimant),
      "claim_review": clean_pii(@claim_review),
      "end_product_establishment": clean_pii(@end_product_establishment),
      "request_issues": clean_pii(@request_issues)
    }.as_json
  end
end
