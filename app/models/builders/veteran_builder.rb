# frozen_string_literal: true

# This class is used to build out a Veteran object from an instance of DecisionReviewCreated
class Builders::VeteranBuilder
  attr_reader :veteran, :decision_review_created

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.veteran
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @veteran = Veteran.new
  end

  def assign_attributes
    assign_participant_id
    calculate_bgs_last_synced_at
    calculate_closest_regional_office
    calculate_date_of_death
    calculate_date_of_death_reported_at
    calculate_name_suffix
    calculate_ssn
    assign_file_number
    assign_first_name
    calculate_middle_name
    assign_last_name
  end

  private

  def assign_participant_id; end

  def calculate_bgs_last_synced_at; end

  def calculate_closest_regional_office; end

  def calculate_date_of_death; end

  def calculate_date_of_death_reported_at; end

  def calculate_name_suffix; end

  def calculate_ssn; end

  def assign_file_number; end

  def assign_first_name; end

  def calculate_middle_name; end

  def assign_last_name; end
end
