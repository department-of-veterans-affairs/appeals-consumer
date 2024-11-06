# frozen_string_literal: true

# A subclass of Event, representing the PersonUpdated Kafka topic event.
class Events::PersonUpdatedEvent < Event
  def process!
    if person_updated_events_pending?
      error_message = "Participant IDs still processing: #{pending_person_updated_events.pluck(:id).join(', ')}"
      fail AppealsConsumer::Error::PriorPersonUpdatedEventsStillPendingError, error_message
    end

    dto = Builders::PersonUpdated::DtoBuilder.new(self)
    response = ExternalApi::CaseflowService.establish_person_updated_records_from_event!(dto)

    handle_response(response)
  rescue AppealsConsumer::Error::ClientRequestError => error
    logger.error(error, { error: error })
    raise error
  rescue StandardError => error
    logger.error(error, { error: error })
    ExternalApi::CaseflowService.establish_person_updated_event_error!(
      id,
      message_payload_hash["participant_id"],
      error.message
    )
    raise error
  end

  private

  def person_updated_events_pending?
    pending_person_updated_events.exists?
  end

  def pending_person_updated_events
    Event.where(participant_id: participant_id)
      .where.not(state: "PROCESSED")
      .where(completed_at: nil)
      .where(
        "(type = 'Events::PersonUpdatedEvent' AND message_payload ->> 'update_time' < ?)",
        message_payload_hash["update_time"]
      )
  end
end
