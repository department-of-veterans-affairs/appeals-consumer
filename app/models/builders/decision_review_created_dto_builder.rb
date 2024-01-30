# frozen_string_literal: true

# This class is ultimately responsible for constructing a DecisionReviewCreated payload
# that will be sent to Caseflow.
# :reek:TooManyInstanceVariables
# :reek:TooManyMethods
class Builders::DecisionReviewCreatedDtoBuilder
  attr_reader :vet_file_number, :vet_ssn, :vet_first_name, :vet_middle_name, :vet_last_name, :claimant_ssn,
              :claimant_dob, :claimant_first_name, :claimant_middle_name, :claimant_last_name, :claimant_email

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def initialize(dcr_event)
    @decision_review_created = DecisionReviewCreated.new(dcr_event.message_payload)
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
  # rubocop:enable Metrics/AbcSize

  private

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

  def retrieve_build_hash_response; end
end
