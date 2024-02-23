# frozen_string_literal: true

# This module is to encapsulate common functionanlity amungst the individiual
# model builder classes such as Builders::EndProductEstablishment
module ModelBuilder
  # used to convert date type to date logical type
  EPOCH_DATE = Date.new(1970, 1, 1)

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
end
