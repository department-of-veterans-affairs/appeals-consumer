# frozen_string_literal: true

class DecisionReviewUpdatedConsumer < ApplicationConsumer
  include LoggerMixin
  EVENT_TYPE = "Events::DecisionReviewUpdatedEvent"

  # rubocop:disable Metrics/MethodLength
  def consume
    MetricsService.record("Consuming and creating messages",
                          service: :kafka,
                          name: "DecisionReviewUpdatedConsumer.consume") do
      messages.each do |message|
        extra_details = extra_details(message)

        log_consumption_start(extra_details)

        begin
          ActiveRecord::Base.transaction do
            event = handle_event_creation(message)

            process_event(event, extra_details) do |new_event|
              DecisionReviewUpdatedEventProcessingJob.perform_later(new_event)
            end
          end
        rescue StandardError => error
          if attempt > 3
            logger.error(error, sentry_details(message), notify_alerts: true)
            next
          else
            logger.error(error, extra_details)
            raise AppealsConsumer::Error::EventConsumptionError, error.message
          end
        end

        log_consumption_end(extra_details)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def handle_event_creation(message)
    Events::DecisionReviewUpdatedEvent.find_or_initialize_by(
      partition: message.metadata.partition,
      offset: message.metadata.offset
    ) do |event|
      event.type = EVENT_TYPE
      event.message_payload = message.payload.message
    end
  end

  def extra_details(message)
    {
      type: EVENT_TYPE,
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      claim_id: message.payload.message["claim_id"]
    }
  end

  def sentry_details(message)
    {
      type: EVENT_TYPE,
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      message_payload: message.payload.message
    }
  end
end
