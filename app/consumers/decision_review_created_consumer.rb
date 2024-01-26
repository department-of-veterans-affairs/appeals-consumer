# frozen_string_literal: true

class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Constants for hardcoded strings
  NOT_STARTED_STATUS = "NOT_STARTED"
  ERROR_MSG = "Error running DecisionReviewCreatedConsumer"
  CONSUMER_NAME = "DecisionReviewCreatedConsumer"

  def consume
    message_arr = messages.map do |message|
      event = handle_event_creation(message.payload)

      #  Perform the job with the created event
      if event&.new_record?
        event.save
        DecisionReviewCreatedJob.perform_later(event)
      end

      # Return the message payload
      message.payload.message
    rescue ActiveRecord::RecordInvalid => error
      handle_error(error, message)
      nil # Return nil to indicate failure
    end

    Karafka.logger.info(message_arr)
  end

  private

  def handle_event_creation(message)
    Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.find_or_initialize_by(
      message_payload: message.message
    ) do |event|
      event.type = message.writer_schema.fullname
      event.state = NOT_STARTED_STATUS
    end
  end

  # Handles errors and notifies via Slack and Sentry
  def handle_error(error, message)
    notify_sentry(error, message)
    notify_slack
  end

  def notify_slack
    slack_message = ERROR_MSG
    slack_message += " See Sentry event #{Sentry.last_event_id}" if Sentry.last_event_id.present?
    slack_service.send_notification(slack_message, CONSUMER_NAME)
  end

  def notify_sentry(error, message)
    Sentry.capture_exception(error) do |scope|
      scope.set_extras({
                         claim_id: message.payload.message["claim_id"],
                         source: CONSUMER_NAME,
                         offset: message.metadata.offset,
                         partition: message.metadata.partition
                       })
    end
  end

  # :reek:UtilityFunction
  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  def slack_service
    @slack_service ||= SlackService.new(url: slack_url)
  end
end
