# frozen_string_literal: true

# TODO: investigate and nail down error handling/notification

# This class is ultimately responsible for constructing a DecisionReviewCreated payload
# that will be sent to Caseflow.
# :reek:TooManyInstanceVariables
# :reek:TooManyMethods
# :reek:InstanceVariableAssumption
class Builders::DecisionReviewCreatedDtoBuilder < Builders::DtoBuilder
  attr_reader :vet_file_number, :vet_ssn, :vet_first_name, :vet_middle_name, :vet_last_name, :claimant_ssn,
              :claimant_dob, :claimant_first_name, :claimant_middle_name, :claimant_last_name, :claimant_email,
              :hash_response

  def initialize(drc_event)
    super()
    @decision_review_created = build_decision_review_created(JSON.parse(drc_event.message_payload))
    @event_id = drc_event.id
    assign_attributes
  end

  private

  # :reek:UtilityFunction
  def build_decision_review_created(message_payload)
    DecisionReviewCreated.new(message_payload)
  end

  # :reek:TooManyStatements
  def assign_attributes
    assign_from_decision_review_created
    assign_from_builders
    assign_from_retrievals
    assign_hash_response
  end

  # :reek:TooManyStatements
  def assign_from_decision_review_created
    @css_id = @decision_review_created.created_by_username
    @detail_type = @decision_review_created.decision_review_type
    @station = @decision_review_created.created_by_station
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
      # TODO: make sure this is notified in sentry/slack
      raise DtoBuildError, "Failed building from Builders::DecisionReviewCreatedDtoBuilder:
        #{error.message}"
    end
  end

  # :reek:TooManyStatements
  def assign_from_retrievals
    @vet_ssn = assign_vet_ssn
    @vet_middle_name = assign_vet_middle_name
    @claimant_ssn = assign_claimant_ssn
    @claimant_dob = assign_claimant_dob
    @claimant_first_name = assign_claimant_first_name
    @claimant_middle_name = assign_claimant_middle_name
    @claimant_last_name = assign_claimant_last_name
    @claimant_email = assign_claimant_email
  end

  def assign_hash_response
    @hash_response = validate_no_pii(build_hash_response)
  end

  def build_intake
    Builders::IntakeBuilder.build(@decision_review_created)
  end

  def build_veteran
    Builders::VeteranBuilder.build(@decision_review_created)
  end

  def build_claimant
    Builders::ClaimantBuilder.build(@decision_review_created)
  end

  def build_claim_review
    Builders::ClaimReviewBuilder.build(@decision_review_created)
  end

  def build_end_product_establishment
    Builders::EndProductEstablishmentBuilder.build(@decision_review_created)
  end

  def build_request_issues
    Builders::RequestIssueCollectionBuilder.build(@decision_review_created)
  end

  def assign_vet_ssn
    @veteran.ssn
  end

  def assign_vet_middle_name
    @veteran.middle_name
  end

  def assign_claimant_ssn
    @claimant.ssn
  end

  def assign_claimant_dob
    @claimant.date_of_birth
  end

  def assign_claimant_first_name
    @claimant.first_name
  end

  def assign_claimant_middle_name
    @claimant.middle_name
  end

  def assign_claimant_last_name
    @claimant.last_name
  end

  def assign_claimant_email
    @claimant.email
  end

  def build_hash_response
    {
      "event_id": @event_id,
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
