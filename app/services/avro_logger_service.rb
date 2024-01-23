# frozen_string_literal: true

class AvroLoggerService < ActiveSupport::Logger
  def error(progname = nil, &block)
    super
    message = block_given? ? yield : progname
    report_error(message)
  end

  private

  def report_error(message)
    notify_sentry(message)
    notify_slack(message)
  end

  def notify_slack(message)
    slack_service.send_notification(message)
  end

  def notify_sentry(message)
    Sentry.capture_message(message, level: "error")
  end

  # :reek:UtilityFunction
  def slack_url
    ENV["SLACK_DISPATCH_ALERT_URL"]
  end

  def slack_service
    @slack_service ||= SlackService.new(url: slack_url)
  end
end
