# frozen_string_literal: true

class HeartbeatJob < ApplicationJob
  queue_as :low_priority

  def perform
    Rails.logger.info "This is a heartbeat ping"
  rescue StandardError => error
    Rails.logger.error(error)
  end
end
