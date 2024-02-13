# frozen_string_literal: true

# Application consumer from which all Karafka consumers should inherit
# You can rename it if it would conflict with your current code base (in case you're integrating
# Karafka with other frameworks)
class ApplicationConsumer < Karafka::BaseConsumer
  ERROR_MSG = "Error running"

  private

  def process_event(event)
    # Check if the event is newly initialized and does not exists in the database already
    if event&.new_record?
      event.save
      yield event if block_given?
      log_consumption_job
    else
      log_repeat_consumption
    end
  rescue ActiveRecord::RecordInvalid => error
    handle_error(error, extra_details(message))
    nil # Return nil to indicate failure
  end

  def log_consumption_start(extra_details)
    log_info("Starting consumption", extra_details)
  end

  def log_consumption_job
    log_info("Dropped Event into processing job")
  end

  def log_repeat_consumption
    log_info("Event record already exists. Skipping enqueueing job")
  end

  def log_consumption_end
    log_info("Completed consumption of message")
  end

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

  def notify_slack
    slack_message = "#{ERROR_MSG} #{self.class.name}"
    slack_message += " See Sentry event #{Sentry.last_event_id}" if Sentry.last_event_id.present?
    slack_service.send_notification(slack_message, self.class.name)
  end

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
