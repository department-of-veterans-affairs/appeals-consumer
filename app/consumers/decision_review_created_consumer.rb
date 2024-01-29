# frozen_string_literal: true

class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Constants for hardcoded strings
  ERROR_MSG = "Error running DecisionReviewCreatedConsumer"
  CONSUMER_NAME = "DecisionReviewCreatedConsumer"

  def consume
    messages.map do |message|
      Karafka.logger.info("[DecisionReviewCreatedConsumer] Starting consumption for partition: #{message.metadata.partition}, offset: #{message.metadata.offset}, with claim_id: #{message.payload.message['claimd_id']}")

      event = handle_event_creation(message.payload)

      #  Perform the job with the created event
      if event&.new_record?
        event.save
        DecisionReviewCreatedJob.perform_later(event)
      end

      Karafka.logger.info("[DecsisionReviewCreateConsumer] Completed consumption of message and dropped Event into processing job")
    rescue ActiveRecord::RecordInvalid => error
      handle_error(error, message)
      nil # Return nil to indicate failure
    end
  end

  private

  def handle_event_creation(message)
    # TODO: This will be replaced by adding partition and offset to the Events table to compare instead of message_payload
    Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.find_or_initialize_by(
      message_payload: message.message
    ) do |event|
      event.type = message.writer_schema.fullname
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
