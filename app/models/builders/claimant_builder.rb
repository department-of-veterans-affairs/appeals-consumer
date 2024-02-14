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
    @bis_record = fetch_bis_record
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
    claimant.payee_code = decision_review_created.payee_code
  end

  def calculate_type
    claimant.type = (decision_review_created.payee_code == "00") ? "VeteranClaimant" : "DepenentClaimant"
  end

  def assign_participant_id
    claimant.participant_id = decision_review_created.claimant_participant_id
  end

  def calculate_name_suffix
    claimant.name_suffix = @bis_record.name_suffix
  end

  def calculate_ssn
    claimant.ssn = @bis_record.ssn
  end

  def calculate_date_of_birth
    claimant.date_of_birth = Date.new(@bis_record.birth_date)
  end

  def calculate_first_name
    claimant.first_name = @bis_record.first_name
  end

  def calculate_middle_name
    claimant.middle_name = @bis_record.middle_name
  end

  def calculate_last_name
    claimant.last_name = @bis_record.last_name
  end

  def calculate_email
    claimant.email = @bis_record.email_address
  end

  def fetch_bis_record
    bis_record = BISService.new.fetch_person_info(decision_review_created.claimant_participant_id)

    # If the result is nil, the veteran wasn't found
    # If the participant id is nil, that's another way of saying the veteran wasn't found
    unless bis_record && bis_record[:ptcpnt_id]
      fail AppealsConsumer::Error::BisClaimantError, "DecisionReviewCreated claimant_participant_id"\
     " #{decision_review_created.claimant_participant_id} does not have a valid BIS record"
    end

    @bis_synced_at = Time.zone.now
    bis_record
  end
end
