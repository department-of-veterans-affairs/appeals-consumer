# frozen_string_literal: true

# A subclass of Event, representing the PersonUpdated Kafka topic event.class Events::PersonUpdatedEvent < Event
  def process!
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
end
