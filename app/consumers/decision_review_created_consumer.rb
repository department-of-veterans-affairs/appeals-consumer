# frozen_string_literal: true

# Example consumer that prints messages payloads
class DecisionReviewCreatedConsumer < ApplicationConsumer
  def consume
    _message_arr = messages.map do |message|
      begin
        event = DecisionReviewCreatedEvent.where(message_payload: message.message)
        event ||= DecisionReviewCreatedEvent.create(
          type: message.writer_schema.fullname,
          message_payload: message.message,
          status: "NOT_STARTED"
        )
      rescue StandardError => error
        # notify slack
        slack_msg = "Error running DecisionReviewCreatedConsumer"
        # slack_msg += " See Sentry event #{Raven.last_event_id}" if Raven.last_event_id.present
        slack_service.send_notification(slack_msg, "DecisiionReviewCreatedConsumer")

        # notify sentry
        Sentry.capture_message(error, level: "error")
      end

      DecisionReviewCreatedJob.perform_later(event)

      decoded_message.message
    end

    Karafka.logger.info message_arr
  end

  private

  # :reek:UtilityFunction
  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  def slack_service
    @slack_service ||= SlackService.new(url: slack_url)
  end
end
