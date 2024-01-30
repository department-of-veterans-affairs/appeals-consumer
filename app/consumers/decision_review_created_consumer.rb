# frozen_string_literal: true

class DecisionReviewCreatedConsumer < ApplicationConsumer
  # Constants for hardcoded strings
  ERROR_MSG = "Error running DecisionReviewCreatedConsumer"
  CONSUMER_NAME = "DecisionReviewCreatedConsumer"
  EVENT_TYPE = "Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent"

  def consume
    messages.map do |message|
      log_consumption_start(message)

      event = handle_event_creation(message.payload)

      #  Perform the job with the created event
      if event&.new_record?
        event.save
        DecisionReviewCreatedJob.perform_later(event)
        log_consumption_job
      end
    rescue ActiveRecord::RecordInvalid => error
      handle_error(error, message)
      nil # Return nil to indicate failure
    end
    log_consumption_end
  end

  private

  def handle_event_creation(message)
    # TODO: This will be replaced by adding partition and offset
    # to the Events table to compare instead of message_payload
    Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.find_or_initialize_by(
      message_payload: message.message
    ) do |event|
      event.type = EVENT_TYPE
    end
  end

  def log_consumption_start(message)
    log_info("Starting consumption", extra_details(message))
  end

  def log_consumption_job
    log_info("Dropped Event into processing job")
  end

  def log_consumption_end
    log_info("Completed consumption of message")
  end

  def log_info(message, extra = {})
    full_message = "[#{CONSUMER_NAME}] #{message}"
    full_message += " | #{extra.to_json}" unless extra.empty?
    Karafka.logger.info(full_message)
  end

  def extra_details(message)
    {
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      claim_id: message.payload.message["claim_id"]
    }
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
                         **extra_details(message),
                         source: CONSUMER_NAME
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
