# frozen_string_literal: true

# This class is a specialized consumer that processes message related to the Decision Review Created kafka topic.
# It processes messages by creating or finding events in the database and enqueues jobs for further processing.
class DecisionReviewCreatedConsumer < ApplicationConsumer
  include LoggerMixin
  # Defines the event type string for decision review created events to standardize the event handling process.
  EVENT_TYPE = Events::DecisionReviewCreatedEvent

  # Consumes messages from the Kafka topic, processing each message to handle event creation,
  # job enqueueing and error management. It iterates over each message, logging the start and end of
  # the consumption process, and uses a block within `process_event` for job execution.
  # rubocop:disable Metrics/MethodLength
  def consume
    MetricsService.record("Consuming and creating messages",
                          service: :kafka,
                          name: "DecisionReviewCreatedConsumer.consume") do
      messages.each do |message|
        claim_id = message.payload.message["claim_id"]
        extra_details = extra_details(message, EVENT_TYPE.to_s,
                                      consumer_specific_details: { claim_id: claim_id })

        log_consumption_start(extra_details)

        begin
          ActiveRecord::Base.transaction do
            event = handle_event_creation(message, EVENT_TYPE)

            # Processes the event with additional logic provided in the block for job enqueueing.
            process_event(event, extra_details) do |new_event|
              # Enqueues a job for further processing of the newly created event.
              DecisionReviewCreatedEventProcessingJob.perform_later(new_event)
            end
          end
        rescue StandardError => error
          if attempt > 3
            logger.error(error, sentry_details(message, EVENT_TYPE.to_s), notify_alerts: true)
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
end
