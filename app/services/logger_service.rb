# frozen_string_literal: true

class LoggerService
  attr_reader :caller_class

  def initialize(caller_class = nil)
    @caller_class = caller_class || self.class.name
  end

  def info(message, extra = {})
    Rails.logger.info(format_message(message, extra))
  end

  def error(message, extra = {}, notify_alerts: false)
    Rails.logger.error(format_message(message, extra))
    notify_error(message, extra) if notify_alerts
  end

  def warn(message, extra = {})
    Rails.logger.warn(format_message(message, extra))
  end

  private

  def format_message(message, extra = {})
    formatted_message = "#{@caller_class} #{message}"
    formatted_message += " | #{extra.to_json}" unless extra.empty?
    formatted_message
  end

  def notify_error(message, extra = {})
    notify_sentry(message, extra)
    notify_slack
  end

  # Sends an error notification message to a configured Slack channel, including a Sentry event id if available.
  def notify_slack
    slack_message = "Error has occured."
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
  def notify_sentry(message, extra = {})
    Raven.capture_exception(extra[:error], message: format_message(message), extra: { **extra, source: @caller_class })
  end
end
