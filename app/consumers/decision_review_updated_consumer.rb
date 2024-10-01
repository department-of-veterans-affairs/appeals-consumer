# frozen_string_literal: true

class DecisionReviewUpdatedConsumer < ApplicationConsumer
  include LoggerMixin
  EVENT_TYPE = Events::DecisionReviewUpdatedEvent

  # rubocop:disable Metrics/MethodLength
  def consume
    MetricsService.record("Consuming messages and creating event records",
                          service: :kafka,
                          name: "DecisionReviewUpdatedConsumer") do
      messages.each do |message|
        claim_id = message.payload.message["claim_id"]
        extra_details = extra_details(message, EVENT_TYPE.to_s,
                                      consumer_specific_details: { claim_id: claim_id })

        log_consumption_start(extra_details)

        begin
          ActiveRecord::Base.transaction do
            event = handle_event_creation(message, EVENT_TYPE)
            if event.message_payload["veteran_participant_id"] == "12345678999" # Number needs to be changed
              fail StandardError, "Testing Error DecisionReviewUpdatedConsumer consume error"
            end

            process_event(event, extra_details) do |new_event|
              DecisionReviewUpdatedEventProcessingJob.perform_later(new_event)
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
