# frozen_string_literal: true

# This class is used to build out a Veteran object from an instance of DecisionReviewCreated
class Builders::VeteranBuilder
  attr_reader :veteran

  def self.build(decision_review_created)
    builder = new
    builder.assign_attributes(decision_review_created)
    builder.veteran
  end

  def initialize
    @veteran = Veteran.new
  end

  def assign_attributes(decision_review_created)
    assign_participant_id(decision_review_created)
    calculate_bgs_last_synced_at(decision_review_created)
    calculate_closest_regional_office(decision_review_created)
    calculate_date_of_death(decision_review_created)
    calculate_date_of_death_reported_at(decision_review_created)
    calculate_name_suffix(decision_review_created)
    calculate_ssn(decision_review_created)
    assign_file_number(decision_review_created)
    assign_first_name(decision_review_created)
    calculate_middle_name(decision_review_created)
    assign_last_name(decision_review_created)
  end

  private

  def assign_participant_id(decision_review_created); end

  def calculate_bgs_last_synced_at(decision_review_created); end

  def calculate_closest_regional_office(decision_review_created); end

  def calculate_date_of_death(decision_review_created); end

  def calculate_date_of_death_reported_at(decision_review_created); end

  def calculate_name_suffix(decision_review_created); end

  def calculate_ssn(decision_review_created); end

  def assign_file_number(decision_review_created); end

  def assign_first_name(decision_review_created); end

  def calculate_middle_name(decision_review_created); end

  def assign_last_name(decision_review_created); end
end
