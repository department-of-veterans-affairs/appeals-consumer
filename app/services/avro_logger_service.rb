# frozen_string_literal: true

class AvroLoggerService < ActiveSupport::Logger
  # Constants for hardcoded strings
  ERROR_MSG = "Error running AvroDeserializerService"
  SERVICE_NAME = "AvroDeserializerService"

  def error(progname = nil, &block)
    super
    error = block_given? ? yield : progname
    report_error(error)
  end

  private

  def report_error(error)
    notify_sentry(error)
    notify_slack
  end

  def notify_slack
    slack_message = ERROR_MSG
    slack_message += " See Sentry event #{Sentry.last_event_id}" if Sentry.last_event_id.present?
    slack_service.send_notification(slack_message, SERVICE_NAME)
  end

  def notify_sentry(error)
    Sentry.capture_exception(error) do |scope|
      scope.set_extras({ source: SERVICE_NAME })
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