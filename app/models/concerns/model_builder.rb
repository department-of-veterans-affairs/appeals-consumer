# frozen_string_literal: true

# This module is to encapsulate common functionanlity amungst the individiual
# model builder classes such as Builders::DecisionReviewCreated::EndProductEstablishment
module ModelBuilder
  # used to convert date type to date logical type
  EPOCH_DATE = Date.new(1970, 1, 1)
  PENSION_IDENTIFIER = "PMC"
  PENSION_BENEFIT_TYPE = "pension"
  COMPENSATION_BENEFIT_TYPE = "compensation"

  def fetch_veteran_bis_record
    return unless @decision_review_created

    bis_record = BISService.new.fetch_veteran_info(@decision_review_created.file_number)

    # If the result is nil, the veteran wasn't found
    # If the participant id is nil, that's another way of saying the veteran wasn't found
    unless bis_record && bis_record[:ptcpnt_id]
      fail AppealsConsumer::Error::BisVeteranNotFound, "DecisionReviewCreated file number"\
     " #{decision_review_created.file_number} does not have a valid BIS record"
    end

    @bis_synced_at = Time.zone.now
    bis_record
  end

  def fetch_limited_poa
    return unless @decision_review_created

    limited_poa = BISService.new.fetch_limited_poas_by_claim_ids(@decision_review_created.claim_id)
    limited_poa ? limited_poa[@decision_review_created.claim_id] : nil
  end

  def fetch_person_bis_record
    bis_record = BISService.new.fetch_person_info(decision_review_created.claimant_participant_id)

    # If the result is empty, the claimant wasn't found
    if bis_record.empty?
      fail AppealsConsumer::Error::BisClaimantNotFound, "DecisionReviewCreated claimant_participant_id"\
     " #{decision_review_created.claimant_participant_id} does not have a valid BIS record"
    end

    bis_record
  end

  def fetch_rating_profile
    return unless @decision_review_created && @issue

    rating_profile = BISService.new.fetch_rating_profile(
      participant_id: @decision_review_created.veteran_participant_id,
      profile_date: @issue.prior_decision_rating_profile_date
    )

    if rating_profile.blank?
      fail AppealsConsumer::Error::BisRatingProfileNotFound, "DecisionReviewCreated veteran_participant_id:"\
      " #{@decision_review_created.veteran_participant_id}, DecisionReviewIssue"\
      " prior_decision_rating_profile_date: #{@issue.prior_decision_rating_profile_date} does not have a"\
      " BIS rating profile"
    end

    rating_profile
  end

  def convert_to_date_logical_type(value)
    Date.parse(value).to_time.to_i / (60 * 60 * 24) if !!value
  end

  def convert_to_timestamp_ms(value)
    DateTime.parse(value).to_i * 1000 if !!value
  end

  def claim_creation_time_converted_to_timestamp_ms
    return unless @decision_review_created

    convert_to_timestamp_ms(@decision_review_created.claim_creation_time)
  end
end
