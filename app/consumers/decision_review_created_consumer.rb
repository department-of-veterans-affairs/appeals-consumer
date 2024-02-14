# frozen_string_literal: true

# This class is a specialized consumer that processes message related to the Decision Review Created kafka topic.
# It processes messages by creating or finding events in the database and enqueues jobs for further processing.
class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Defines the event type string for decision review created events to standardize the event handling process.
  EVENT_TYPE = "Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent"

  # Consumes messages from the Kafka topic, processing each message to handle event creation,
  # job enqueueing and error management. It iterates over each message, logging the start and end of
  # the consumption process, and uses a block within `process_event` for job execution.
  def consume
    messages.each do |message|
      extra_details = extra_details(message)

      log_consumption_start(extra_details)

      begin
        event = handle_event_creation(message)

        # Processes the event with additional logic provided in the block for job enqueueing.
        process_event(event, extra_details) do |new_event|
          # Enqueues a job for further processing of the newly created event.
          DecisionReviewCreatedJob.perform_later(new_event)
        end
      rescue ActiveRecord::RecordInvalid => error
        # Handles any ActiveRecord validation errors by logging and notifying the error.
        handle_error(error, extra_details)
      end

      log_consumption_end(extra_details)
    end
  end

  private

  # Attempts to find or initialize a new decision review created event based on message metadata.
  # This method ensures that each event is uniquely identified by its poartition and offset,
  # preventing duplicate processing of the same event.
  def handle_event_creation(message)
    Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.find_or_initialize_by(
      partition: message.metadata.partition,
      offset: message.metadata.offset
    ) do |event|
      event.type = EVENT_TYPE
      event.message_payload = message.payload.message
    end
  end

  # Extracts and returns a hash of extra details from the message for logging and diagnostic purposes.
  # These details include the kafka partition, offset, and the claim ID extracted from the message payload.
  def extra_details(message)
    {
      type: EVENT_TYPE,
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      claim_id: message.payload.message["claim_id"]
    }
  end
end
