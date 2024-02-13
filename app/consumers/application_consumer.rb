# frozen_string_literal: true

# This class serves as the base consumer for all Karafka message consumption within the application.
# It abstracts common functionality needed across different consumers, such as event processing,
# logging, and error handling. This setup promotes reuse and consistency in handling incoming
# messages from Kafka topics.
class ApplicationConsumer < Karafka::BaseConsumer
  # Constant defined for generic error message prefix used in notifications.
  ERROR_MSG = "Error running"

  private

  # processes a given event, saving it to the database if it's new and logging the operation.
  def process_event(event, extra_details)
    # Determines if the event is new and not yet saved in the database.
    if event&.new_record?
      event.save

      yield event if block_given?
      log_consumption_job({
                            **extra_details,
                            event_id: event.id
                          })
    else
      log_repeat_consumption({
                               **extra_details,
                               event_id: event.id
                             })
    end
  end

  # Logs the start of an event consumption with extra details for diagnostic purposes.
  def log_consumption_start(extra_details)
    log_info("Starting consumption", extra_details)
  end

  # Logs the successful enqueueing of an event consumption into a processing job.
  def log_consumption_job(extra_details)
    log_info("Dropped Event into processing job", extra_details)
  end

  # Logs an attempt to process an event that already exists in the database, indicating no further action was taken.
  def log_repeat_consumption(extra_details)
    log_info("Event record already exists. Skipping enqueueing job", extra_details)
  end

  # Logs the start of an event consumption with extra details for diagnostic purposes.
  def log_consumption_end(extra_details)
    log_info("Completed consumption of message", extra_details)
  end

  # Utility method for logging information with a consisten format, including the class name and optional details.
  def log_info(message, extra = {})
    full_message = "[#{self.class.name}] #{message}"
    full_message += " | #{extra.to_json}" unless extra.empty?
    Karafka.logger.info(full_message)
  end

  # Handles errors and notifies via Slack and Sentry
  def handle_error(error, extra_details = {})
    notify_sentry(error, extra_details)
    notify_slack
  end

  # Sends an error notification message to a configured Slack channel, including a Sentry event id if available.
  def notify_slack
    slack_message = "#{ERROR_MSG} #{self.class.name}"
    slack_message += " See Sentry event #{Sentry.last_event_id}" if Sentry.last_event_id.present?
    slack_service.send_notification(slack_message, self.class.name)
  end

  # Reports an exception to Sentry, including additional details for debugging.
  def notify_sentry(error, extra_details)
    Sentry.capture_exception(error) do |scope|
      scope.set_extras({
                         **extra_details,
                         source: self.class.name
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
