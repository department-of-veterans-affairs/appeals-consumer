# frozen_string_literal: true

class Builders::ModelBuilder
  # all dates are converted to logical type int by
  # subtracting EPOCH_DATE from the date and converting to an integer
  EPOCH_DATE = Date.new(1970, 1, 1)

  # used to determine the Claim Review's benefit type
  # if an ep_code includes this string, it is "pension" benefit type
  # otherwise, it is "compensation" benefit type
  PENSION_IDENTIFIER = "PMC"

  def fetch_veteran_bis_record
    bis_record = BISService.new.fetch_veteran_info(decision_review_created.file_number)

    # If the result is nil, the veteran wasn't found
    # If the participant id is nil, that's another way of saying the veteran wasn't found
    unless bis_record && bis_record[:ptcpnt_id]
      fail AppealsConsumer::Error::BisVeteranNotFound, "DecisionReviewCreated veteran file number"\
     " #{decision_review_created.file_number} does not have a valid BIS record"
    end

    @bis_synced_at = Time.zone.now
    bis_record
  end
end
