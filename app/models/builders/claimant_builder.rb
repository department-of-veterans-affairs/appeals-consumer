# frozen_string_literal: true

# This class is used to build out a Claimant object from an instance of DecisionReviewCreated
class Builders::ClaimantBuilder
  attr_reader :claimant, :decision_review_created

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.claimant
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @claimant = Claimant.new
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

  def assign_payee_code; end

  def calculate_type; end

  def assign_participant_id; end

  def calculate_name_suffix; end

  def calculate_ssn; end

  def calculate_date_of_birth; end

  def calculate_first_name; end

  def calculate_middle_name; end

  def calculate_last_name; end

  def calculate_email; end
end
