# frozen_string_literal: true

class AvroLoggerService < ActiveSupport::Logger
  include LoggerMixin

  # Constants for hardcoded strings
  ERROR_MSG = "Error running AvroDeserializerService"
  SERVICE_NAME = "AvroDeserializerService"

  def error(progname = nil, &block)
    super
    error = block_given? ? yield : progname
    logger.error(error, notify_alerts: true)
  end
end
