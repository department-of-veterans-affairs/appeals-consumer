# frozen_string_literal: true

class EventProcessingRescueJob < BaseEventProcessingJob
  def perform
    start_time = Time.zone.now
    stuck_audits = Audit.stuck
    stuck_audits.find_each do |audit|
      break if time_exceeded?(start_time)

      audit.cancelled!
      audit.ended_at!
    end

    Event.where.not(status: "PROCESSED").find_each do |event|
      break if time_exceeded?(start_time)

      DecisionReviewCreatedEventProcessingJob.perform_later(event)
    end
  end

  private

  def time_exceeded?(start_time)
    Time.zone.now - start_time > 25.minutes
  end
end
