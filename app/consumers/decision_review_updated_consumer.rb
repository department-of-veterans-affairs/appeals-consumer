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
        decision_review_updated_extra_details = decision_review_updated_extra_details(message)

        log_consumption_start(decision_review_updated_extra_details)

        begin
          ActiveRecord::Base.transaction do
            event = handle_event_creation(message, EVENT_TYPE)

            process_event(event, decision_review_updated_extra_details) do |new_event|
              DecisionReviewUpdatedEventProcessingJob.perform_later(new_event)
            end
          end
        rescue StandardError => error
          if attempt > 3
            logger.error(error, sentry_details(message, EVENT_TYPE), notify_alerts: true)
            next
          else
            logger.error(error, decision_review_updated_extra_details)
            raise AppealsConsumer::Error::EventConsumptionError, error.message
          end
        end

        log_consumption_end(decision_review_updated_extra_details)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def decision_review_updated_extra_details(message)
    {
      type: EVENT_TYPE,
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      claim_id: message.payload.message["claim_id"]
    }
  end
end
