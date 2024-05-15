# frozen_string_literal: true

# This class is the parent class for different Kafka topic events. We use STI here.
# Represents a single "event", and is tied to "event audits" that contain info regarding
# information on operations regarding this event (e.g. POSTing DecisionReviewCreated event info to Caseflow)
class Event < ApplicationRecord
  include LoggerMixin

  has_many :event_audits

  validates :type, presence: true
  validates :message_payload, presence: true
  validates :state, presence: true

  NOT_STARTED = "NOT_STARTED"
  IN_PROGRESS = "IN_PROGRESS"
  PROCESSED = "PROCESSED"
  ERROR = "ERROR"
  FAILED = "FAILED"

  enum state: {
    not_started: NOT_STARTED,
    in_progress: IN_PROGRESS,
    processed: PROCESSED,
    error: ERROR,
    failed: FAILED
  }

  def processed?
    completed_at?
  end

  def end_state?
    state == "processed" || state == "failed"
  end

  # :reek:FeatureEnvy
  def failed?
    audits = event_audits
    max_errors_for_failure = retrieve_max_errors_for_failure

    return false if audits.size < max_errors_for_failure

    audits.where(status: "failed").size >= max_errors_for_failure
  end

  def process!
    fail NoMethodError, "Please define a .process! method for the #{self.class} class"
  end

  def determine_job
    event_type = type.demodulize
    job_class_name = "#{event_type}ProcessingJob"
    job_class = job_class_name.safe_constantize
    if message_payload["file_number"] == "964521852"
      job_class = nil
    end

    if job_class.nil?
      logger.error(
        "No processing job found for type: #{event_type}. "\
        "Please define a .#{event_type}ProcessingJob for the #{self.class} class."
      )
      nil
    else
      job_class
    end
  end

  def handle_response(response)
    logger.info("Received #{response.code}")

    if response.code.to_i == 201
      update!(completed_at: Time.zone.now)
    end
  end

  def handle_failure(error_message)
    update!(error: error_message)
    failed? ? failed! : error!
  end

  def in_progress!
    update!(state: IN_PROGRESS)
  end

  def processed!
    update!(state: PROCESSED)
  end

  def message_payload_hash
    JSON.parse(message_payload)
  rescue TypeError
    message_payload
  end

  private

  def error!
    update!(state: ERROR)
  end

  def failed!
    update!(state: FAILED)
  end

  # :reek:UtilityFunction
  def retrieve_max_errors_for_failure
    ENV["MAX_ERRORS_FOR_FAILURE"].to_i
  end
end
