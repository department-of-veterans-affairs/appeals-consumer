# frozen_string_literal: true

# This class is used to build out a Claimant object from an instance of DecisionReviewCreated
class Builders::ClaimantBuilder
  attr_reader :claimant

  def self.build(decision_review_created)
    builder = new
    builder.assign_attributes(decision_review_created)
    builder.claimant
  end

  def initialize
    @claimant = Claimant.new
  end

  def assign_attributes(decision_review_created)
    assign_payee_code(decision_review_created)
    calculate_type(decision_review_created)
    assign_participant_id(decision_review_created)
    calculate_name_suffix(decision_review_created)
    calculate_ssn(decision_review_created)
    calculate_date_of_birth(decision_review_created)
    calculate_first_name(decision_review_created)
    calculate_middle_name(decision_review_created)
    calculate_last_name(decision_review_created)
    calculate_email(decision_review_created)
  end

  private

  def assign_payee_code(decision_review_created); end

  def calculate_type(decision_review_created); end

  def assign_participant_id(decision_review_created); end

  def calculate_name_suffix(decision_review_created); end

  def calculate_ssn(decision_review_created); end

  def calculate_date_of_birth(decision_review_created); end

  def calculate_first_name(decision_review_created); end

  def calculate_middle_name(decision_review_created); end

  def calculate_last_name(decision_review_created); end

  def calculate_email(decision_review_created); end
end
