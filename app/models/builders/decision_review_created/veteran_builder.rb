# frozen_string_literal: true

# This class is used to build out a DecisionReviewCreated::Veteran object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::VeteranBuilder
  # include DecisionReviewCreated::ModelBuilder
  include DecisionReview::ModelBuilder
  attr_reader :veteran, :decision_review_created, :bis_record

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.veteran
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @veteran = DecisionReviewCreated::Veteran.new
    @bis_record = fetch_veteran_bis_record
  end

  def assign_attributes
    assign_participant_id
    assign_file_number
    assign_first_name
    assign_last_name
    calculate_bgs_last_synced_at
    calculate_date_of_death
    calculate_name_suffix
    calculate_ssn
    calculate_middle_name
  end

  private

  def assign_participant_id
    @veteran.participant_id = decision_review_created.veteran_participant_id
  end

  def assign_file_number
    @veteran.file_number = decision_review_created.file_number
  end

  def assign_first_name
    @veteran.first_name = decision_review_created.veteran_first_name
  end

  def assign_last_name
    @veteran.last_name = decision_review_created.veteran_last_name
  end

  def calculate_bgs_last_synced_at
    @veteran.bgs_last_synced_at = convert_bis_synced_at_to_milliseconds
  end

  def calculate_date_of_death
    @veteran.date_of_death = convert_date_of_death_to_logical_type_int
  end

  def calculate_name_suffix
    @veteran.name_suffix = bis_record&.dig(:name_suffix)
  end

  def calculate_ssn
    @veteran.ssn = bis_record&.dig(:ssn)
  end

  def calculate_middle_name
    @veteran.middle_name = bis_record&.dig(:middle_name)
  end

  def convert_bis_synced_at_to_milliseconds
    @bis_synced_at.to_i * 1000
  end

  def convert_date_of_death_to_logical_type_int
    date = bis_record&.dig(:date_of_death)

    if date
      target_date = Date.strptime(date, "%m/%d/%Y")
      (target_date - EPOCH_DATE).to_i
    end
  end
end
