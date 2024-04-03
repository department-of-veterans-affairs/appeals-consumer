# frozen_string_literal: true

# LoggerService class provides a unified formating for logging and additional functionality for Slack and Sentry alerts.
class LoggerService < SimpleDelegator
  attr_reader :caller_class

  def initialize(caller_class = nil)
    super(Rails.logger)
    @caller_class = caller_class || self.class.name
  end

  # Logs an info message with optional extra information, sanitizing sensitive data.
  def info(message, extra = {})
    super(format_message(message, PiiSanitizer.sanitize(extra)))
  end

  # Logs an error message with optional extra information, sanitizing sensitive data.
  # Optionally, will notify Sentry and Slack based on the `notify_alerts` parameter.
  def error(error, extra = {}, notify_alerts: false)
    super(format_message(handle_error_message(error), PiiSanitizer.sanitize(extra)))
    notify_error(error, extra) if notify_alerts
  end

  # Logs a warning message with optional extra information, sanitizing sensitive data.
  def warn(message, extra = {})
    super(format_message(message, PiiSanitizer.sanitize(extra)))
  end

  private

  # Formats the log message with a caller class tag. Also, add extra data when available.
  def format_message(message, extra = {})
    formatted_message = "[#{@caller_class}] #{message}"
    formatted_message += " | #{extra.to_json}" unless extra.empty?
    formatted_message
  end

  def notify_error(error, extra = {})
    notify_sentry(error, extra)
    notify_slack(extra)
  end

  # Sends an error notification message to a configured Slack channel, including a Sentry event id if available.
  def notify_slack(extra = {})
    slack_message = "Error has occured"
    slack_message += extra[:event_id].nil? ? "." : " for event ID: #{extra[:event_id]}."
    slack_message += " See Sentry event #{Raven.last_event_id}" if Raven.last_event_id.present?
    slack_service.send_notification(format_message(slack_message))
  end

  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  def slack_service
    @slack_service ||= SlackService.new(url: slack_url)
  end

  # Reports an exception to Sentry, including additional details for debugging.
  def notify_sentry(error, extra = {})
    Raven.capture_exception(error,
                            extra: { **extra,
                              source: @caller_class,
                              message: format_message(handle_error_message(error)) })
  end

  # handles an error message to ensure that it's in a string format of the error's message.
  def handle_error_message(error)
    error.is_a?(Exception) ? error.message : error
  end
end
