# frozen_string_literal: true

class DecisionReviewUpdatedConsumer < ApplicationConsumer
  include LoggerMixin
  EVENT_TYPE = "Events::DecisionReviewUpdatedEvent"

  # rubocop:disable Metrics/MethodLength
  def consume
    MetricsService.record("Consuming messages and creating event records",
                          service: :kafka,
                          name: "DecisionReviewUpdatedConsumer") do
      messages.each do |message|
        extra_details = extra_details(message, EVENT_TYPE,
                                      consumer_specific_details: { claim_id: message.payload.message["claim_id"] })

        log_consumption_start(extra_details)

        begin
          ActiveRecord::Base.transaction do
            event = handle_event_creation(message, EVENT_TYPE)

            process_event(event, extra_details) do |new_event|
              DecisionReviewUpdatedEventProcessingJob.perform_later(new_event)
            end
          end
        rescue StandardError => error
          if attempt > 3
            logger.error(error, sentry_details(message, EVENT_TYPE), notify_alerts: true)
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
