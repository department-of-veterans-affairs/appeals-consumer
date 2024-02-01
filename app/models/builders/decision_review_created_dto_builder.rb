# frozen_string_literal: true

# This class is ultimately responsible for constructing a DecisionReviewCreated payload
# that will be sent to Caseflow.
# :reek:TooManyInstanceVariables
# :reek:TooManyMethods
class Builders::DecisionReviewCreatedDtoBuilder < Builders::DtoBuilder
  attr_reader :vet_file_number, :vet_ssn, :vet_first_name, :vet_middle_name, :vet_last_name, :claimant_ssn,
              :claimant_dob, :claimant_first_name, :claimant_middle_name, :claimant_last_name, :claimant_email

  def initialize(dcr_event = nil)
    super
    @decision_review_created = build_decision_review_created(dcr_event.message_payload) if dcr_event
    @decision_review_created ? assign_attributes : reset_attributes
  end

  private

  # :reek:UtilityFunction
  def build_decision_review_created(message_payload)
    DecisionReviewCreated.new(message_payload)
  end

  # :reek:TooManyStatements
  # rubocop:disable Metrics/MethodLength
  def assign_attributes
    @css_id = @decision_review_created.created_by_username
    @detail_type = @decision_review_created.decision_review_type
    @station = @decision_review_created.created_by_station
    @intake = build_intake
    @veteran = build_veteran
    @claimant = build_claimant
    @claim_review = build_claim_review
    @end_product_establishment = build_end_product_establishment
    @request_issues = build_request_issues
    @vet_file_number = @decision_review_created.veteran_file_number
    @vet_ssn = retrieve_vet_ssn
    @vet_first_name = @decision_review_created.veteran_first_name
    @vet_middle_name = retrieve_vet_middle_name
    @vet_last_name = @decision_review_created.veteran_last_name
    @claimant_ssn = retrieve_claimant_ssn
    @claimant_dob = retrieve_claimant_dob
    @claimant_first_name = retrieve_claimant_first_name
    @claimant_middle_name = retrieve_claimant_middle_name
    @claimant_last_name = retrieve_claimant_last_name
    @claimant_email = retrieve_claimant_email
    @hash_response = build_hash_response
  end
  # rubocop:enable Metrics/MethodLength

  # :reek:TooManyStatements
  # rubocop:disable Metrics/MethodLength
  def reset_attributes
    @css_id = nil
    @detail_type = nil
    @station = nil
    @intake = nil
    @veteran = nil
    @claimant = nil
    @claim_review = nil
    @end_product_establishment = nil
    @request_issues = nil
    @vet_file_number = nil
    @vet_ssn = nil
    @vet_first_name = nil
    @vet_middle_name = nil
    @vet_last_name = nil
    @claimant_ssn = nil
    @claimant_dob = nil
    @claimant_first_name = nil
    @claimant_middle_name = nil
    @claimant_last_name = nil
    @claimant_email = nil
    @hash_response = nil
  end
  # rubocop:enable Metrics/MethodLength

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
    Builders::RequestIssueBuilder.build(@decision_review_created.decision_review_issues)
  end

  def retrieve_vet_ssn; end

  def retrieve_vet_middle_name; end

  def retrieve_claimant_ssn; end

  def retrieve_claimant_dob; end

  def retrieve_claimant_first_name; end

  def retrieve_claimant_middle_name; end

  def retrieve_claimant_last_name; end

  def retrieve_claimant_email; end

  def build_hash_response
    # maybe something like this?
    # {
    #   ...
    #   "intake": @intake.as_json(except: PII_FIELDS),
    #   "veteran": @veteran.as_json(except: PII_FIELDS),
    #   "claimant": @claimant.as_json(except: PII_FIELDS),
    #   ...
    # }
  end
end
