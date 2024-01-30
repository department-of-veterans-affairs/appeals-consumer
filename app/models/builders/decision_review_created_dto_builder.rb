# frozen_string_literal: true

# This class is ultimately responsible for constructing a DecisionReviewCreated payload
# that will be sent to Caseflow.
class Builders::DecisionReviewCreatedDtoBuilder

  attr_reader :vet_file_number, :vet_ssn, :vet_first_name, :vet_middle_name, :vet_last_name,
    :claimant_ssn, :claimant_dob, :claimant_first_name, :claimant_middle_name, :claimant_last_name
    :claimant_email

  def initialize(dcr_event)
    @decision_review_created = DecisionReviewCreated.new(dcr_event.message_payload)
    @css_id = @decision_review_created.css_id
    @detail_type = @decision_review_created.detail_type
    @station = @decision_review_created.station
    @intake = build_intake
    @veteran = build_veteran
    @claimant = build_claimant
    @claim_review = build_claim_review
    @end_product_establishment = build_end_product_establishment
    @request_issues = build_request_issues
    @vet_file_number = @decision_review_created.veteran_file_number
    @vet_ssn = vet_ssn
    @vet_first_name = @decision_review_created.veteran_first_name
    @vet_middle_name = vet_middle_name
    @vet_last_name = @decision_review_created.veteran_last_name
    @claimant_ssn = claimant_ssn
    @claimant_dob = claimant_dob
    @claimant_first_name = claimant_first_name
    @claimant_middle_name = claimant_middle_name
    @claimant_last_name = claimant_last_name
    @claimant_email = claimant_email
    @hash_response = build_hash_response
  end

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

  def vet_ssn
  end

  def vet_middle_name
  end

  def claimant_ssn
  end

  def claimant_dob
  end

  def claimant_first_name
  end

  def claimant_middle_name
  end

  def claimant_last_name
  end

  def claimant_email
  end

  def build_hash_response
  end
end