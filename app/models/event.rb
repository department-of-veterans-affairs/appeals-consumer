# frozen_string_literal: true

# This class is the parent class for different Kafka topic events. We use STI here.
# Represents a single "event", and is tied to "event audits" that contain info regarding
# information on operations regarding this event (e.g. POSTing DecisionReviewCreated event info to Caseflow)
class Event < ApplicationRecord
  has_many :event_audits

  validates :type, presence: true
  validates :message_payload, presence: true
  validates :state, presence: true

  enum state: {
    not_started: "NOT_STARTED",
    in_progress: "IN_PROGRESS",
    processed: "PROCESSED",
    error: "ERROR",
    failed: "FAILED"
  }

  def processed?
    completed_at?
  end

  # :reek:FeatureEnvy
  def failed?
    audits = event_audits
    max_errors_for_failure = retrieve_max_errors_for_failure

    return false if audits.size < max_errors_for_failure

    audits.map(&:error).last(max_errors_for_failure).include?(nil) ? false : true
  end

  def self.process!
    fail NoMethodError, "Please define a .process! method for the #{self} class"
  end

  def handle_response(response)
    if response.code.to_i == 201
      update!(completed_at: Time.zone.now)
    end
    Rails.logger.info("Received #{code}")
  end

  def handle_client_error(error_message)
    Rails.logger.error(error_message)
    update!(error: error_message)
  end
  

  private

  # :reek:UtilityFunction
  def retrieve_max_errors_for_failure
    ENV["MAX_ERRORS_FOR_FAILURE"].to_i
  end
end
