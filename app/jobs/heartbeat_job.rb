# frozen_string_literal: true

class HeartbeatJob < ApplicationJob
  include LoggerMixin

  queue_as :low_priority

  def perform
    logger.info "This is a heartbeat ping"
  rescue StandardError => error
    logger.error(error)
  end
end
