# frozen_string_literal: true

class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Constants for hardcoded strings
  NOT_STARTED_STATUS = "NOT_STARTED"
  ERROR_MSG = "Error running DecisionReviewCreatedConsumer"
  CONSUMER_NAME = "DecisionReviewCreatedConsumer"

  def consume
    message_arr = messages.map do |message|
      event = handle_event_creation(message)

      #  Perform the job with the created event
      DecisionReviewCreatedJob.perform_later(event) if event

      # Return the decoded message
      message.message
    end

    Karafka.logger.info(message_arr)
  end

  private

  def handle_event_creation(message)
    DecisionReviewCreatedEvent.find_or_create_by(
      message_payload: message.message
    ) do |event|
      event.type = message.writer_schema.fullname
      event.status = NOT_STARTED_STATUS
    end
  rescue ActiveRecord::RecordInvalid => error
    handle_error(error)
    nil # Return nil to indicate failure
  end

  # Handles errors and notifies via Slack and Sentry
  def handle_error(error)
    notify_slack
    notify_sentry(error)
  end

  def notify_slack
    slack_service.send_notification(ERROR_MSG, CONSUMER_NAME)
  end

  def notify_sentry(error)
    Sentry.capture_message(error, level: "error")
  end

  # :reek:UtilityFunction
  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  def slack_service
    @slack_service ||= SlackService.new(url: slack_url)
  end
end
