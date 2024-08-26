# frozen_string_literal: true

# This class is used to build out a DecisionReviewCreated::Claimant object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::ClaimantBuilder
  include DecisionReview::ModelBuilderHelper
  attr_reader :claimant, :decision_review_model, :bis_record

  VETERAN_TYPE = "VeteranClaimant"
  DEPENDENT_TYPE = "DependentClaimant"

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.assign_attributes
    builder.claimant
  end

  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
    @claimant = DecisionReviewCreated::Claimant.new
    @bis_record = fetch_person_bis_record
  end

  def assign_attributes
    assign_payee_code
    calculate_type
    assign_participant_id
    calculate_name_suffix
    calculate_ssn
    calculate_date_of_birth
    calculate_first_name
    calculate_middle_name
    calculate_last_name
    calculate_email
  end

  private

  def assign_payee_code
    claimant.payee_code = decision_review_model.payee_code
  end

  def calculate_type
    claimant.type = (decision_review_model.payee_code == "00") ? VETERAN_TYPE : DEPENDENT_TYPE
  end

  def assign_participant_id
    claimant.participant_id = decision_review_model.claimant_participant_id
  end

  def calculate_name_suffix
    claimant.name_suffix = @bis_record&.dig(:name_suffix)
  end

  def calculate_ssn
    claimant.ssn = @bis_record&.dig(:ssn)
  end

  def calculate_date_of_birth
    claimant.date_of_birth = @bis_record&.dig(:birth_date).to_i * 1000 if @bis_record&.dig(:birth_date)
  end

  def calculate_first_name
    claimant.first_name = @bis_record&.dig(:first_name)
  end

  def calculate_middle_name
    claimant.middle_name = @bis_record&.dig(:middle_name)
  end

  def calculate_last_name
    claimant.last_name = @bis_record&.dig(:last_name)
  end

  def calculate_email
    claimant.email = @bis_record&.dig(:email_address)
  end
end
