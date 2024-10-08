# frozen_string_literal: true

# This class is a specialized consumer that processes message related to the person updated...

class PersonUpdatedConsumer < ApplicationConsumer
    include LoggerMixin
    EVENT_TYPE = Events::PersonUpdatedEvent
  
    # rubocop:disable Metrics/MethodLength
    def consume
      MetricsService.record("Consuming messages and creating event records",
                            service: :kafka,
                            name: "PersonUpdatedConsumer") do
        messages.each do |message|
          participant_id = message.payload.message["participant_id"] #maybe?
          extra_details = extra_details(message, EVENT_TYPE.to_s,
                            consumer_specific_details: { participant_id: participant_id }) #maybe?
  
          log_consumption_start(extra_details)
  
          begin
            ActiveRecord::Base.transaction do
              event = handle_event_creation(message, EVENT_TYPE)
  
              process_event(event, extra_details) do |new_event|
                PersonUpdatedEventProcessingJob.perform_later(new_event)
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
  