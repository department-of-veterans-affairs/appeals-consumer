# frozen_string_literal: true

class EventProcessingRescueJob < ApplicationJob
  include LoggerMixin

  queue_as :high_priority

  rescue_from(StandardError) do |error|
    puts "EventProcessingRescueJob#perform rescue block was entered at #{Time.zone.now}"
    logger.error("Encountered an exception.", extra_details(error: error))
  end

  def perform
    MetricsService.record("Event rescue processing",
                          service: :event_processing_rescue_job,
                          name: "EventProcessingRescueJob.perform") do
      start_processing!
      stuck_audits = EventAudit.stuck
      # Fake Claim ID that doesn't exist in Production env used to test EventProcessingRescueJob error handling
      if stuck_audits&.first&.event&.message_payload_hash&.dig("claim_id") == 12
        fail StandardError, "EventProcessingRescueJob#perform StandardError"
      end

      stuck_audits.find_each do |audit|
        if time_exceeded?
          logger.info("Time limit exceeded, stopping job execution.")
          break
        end

        process_audit(audit)
        @processed_audits_count += 1
      end
      complete_processing!
    end
  end

  private

  def start_processing!
    @start_time = Time.zone.now
    # Fake Claim ID that doesn't exist in Production env used to test EventProcessingRescueJob time limit
    if EventAudit.stuck.any? { |stuck_audit| stuck_audit.event.message_payload_hash["claim_id"] == 10 }
      @start_time = Time.zone.now - 26.minutes
    end
    @processed_audits_count = 0
    logger.info("Process started at #{@start_time}.")
  end

  def complete_processing!
    processing_time = Time.zone.now - @start_time
    logger.info(
      "Process completed. Total audits processed: #{@processed_audits_count}. "\
      "Processing time: #{processing_time.round(2)} seconds."
    )
  end

  def time_exceeded?
    Time.zone.now - @start_time > 25.minutes
  end

  def process_audit(audit)
    # Fake Claim ID that doesn't exist in Production env used to test EventProcessingRescueJob error handling
    if audit.event.message_payload_hash["claim_id"] == 13
      fail StandardError, "EventProcessingRescueJob#process_audit StandardError"
    end

    ActiveRecord::Base.transaction do
      audit.cancelled!
      audit.ended_at!
      audit.update!(
        notes: audit_concatenated_notes(audit)
      )
    end

    logger.info("EventAudit was cancelled.", extra_details(audit: audit, event: audit.event))

    handle_reenqueue(audit.event)
  rescue StandardError => error
    puts "EventProcessingRescueJob#perform rescue block was entered at #{Time.zone.now}"
    logger.error("Failed to process EventAudit.", extra_details(audit: audit, event: audit.event, error: error))
  end

  def handle_reenqueue(event)
    return if event.end_state?
    # Fake Claim ID that doesn't exist in Production env used to test EventProcessingRescueJob error handling
    if event.message_payload_hash["claim_id"] == 14
      fail StandardError, "EventProcessingRescueJob#handle_reenqueue StandardError"
    end

    job_class = event.determine_job
    if job_class
      job_class.perform_later(event)
      logger.info(
        "Event with id: #{event.id} was found to be not \"PROCESSED\" and was re-enqueued into a new processing job."
      )
    else
      logger.error("Failed to re-enqueue job for Event.", extra_details(event: event))
    end
  rescue StandardError => error
    puts "EventProcessingRescueJob#perform rescue block was entered at #{Time.zone.now}"
    logger.error("Error during the re-enqueue for Event.", extra_details(event: event, error: error))
  end

  def extra_details(audit: nil, event: nil, error: nil)
    data = {}
    data[:event_audit_id] = audit.id if audit
    if event
      data[:event_id] = event.id
      data[:type] = event.type
    end
    data[:error_message] = error.message if error
    data
  end

  def audit_concatenated_notes(audit)
    msg = "EventAudit was left in an uncompleted state for longer "\
        "than 26 minutes and was marked as \"CANCELLED\" at #{Time.zone.now}."
    return msg if audit.notes.nil?

    "#{audit.notes} - #{msg}"
  end
end
