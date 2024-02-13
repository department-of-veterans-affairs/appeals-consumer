# frozen_string_literal: true

class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Constant for hardcoded strings
  EVENT_TYPE = "Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent"

  def consume
    messages.map do |message|
      log_consumption_start(extra_details(message))

      begin
        event = handle_event_creation(message)

        process_event(event) do |new_event|
          #  Perform the job with the created event
          DecisionReviewCreatedJob.perform_later(new_event)
        end
      rescue ActiveRecord::RecordInvalid => error
        handle_error(error, extra_details(message))
        nil # Return nil to indicate failure
      end

      log_consumption_end
    end
  end

  private

  def handle_event_creation(message)
    Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.find_or_initialize_by(
      partition: message.metadata.partition,
      offset: message.metadata.offset
    ) do |event|
      event.type = EVENT_TYPE
      event.message_payload = message.payload.message
    end
  end

  def extra_details(message)
    {
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      claim_id: message.payload.message["claim_id"]
    }
  end
end
