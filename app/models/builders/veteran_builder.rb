# frozen_string_literal: true

# This class is used to build out a Veteran object from an instance of DecisionReviewCreated
class Builders::VeteranBuilder
  attr_reader :veteran, :decision_review_created, :bis_record

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.veteran
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @veteran = Veteran.new
    @bis_record = fetch_bis_record
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
    @veteran.bgs_last_synced_at = @bis_synced_at
  end

  def calculate_date_of_death
    @veteran.date_of_death = bis_record[:date_of_death]
  end

  def calculate_name_suffix
    @veteran.name_suffix = bis_record[:name_suffix]
  end

  def calculate_ssn
    @veteran.ssn = bis_record[:ssn]
  end

  def calculate_middle_name
    @veteran.middle_name = bis_record[:middle_name]
  end

  def fetch_bis_record
    bis_record = BISService.new.fetch_veteran_info(decision_review_created.file_number)

    # If the result is nil, the veteran wasn't found
    # If the participant id is nil, that's another way of saying the veteran wasn't found
    unless bis_record && bis_record[:ptcpnt_id]
      fail AppealsConsumer::Error::BisVeteranNotFound, "DecisionReviewCreated file number"\
     " #{decision_review_created.file_number} does not have a valid BIS record"
    end

    @bis_synced_at = Time.zone.now
    bis_record
  end
end
