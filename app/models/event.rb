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

  def process!
    dto = DecsisionReviewCreatedDTOBuilder.new(self)
    response = CaseflowService.establish_decision_review_created_records_from_event(dto)

    Rails.logger.info("Received #{response.code}")

    if response.code == 201
      update!(completed_at: Time.zone.now)
    end
  rescue AppealsConsumer::Error::ClientRequestError => error
    Rails.logger.error(error.message)
    update!(error: error.message)
  rescue StandardError => error
    response = CaseflowService.establish_decision_review_created_event_error(
      id,
      message_payload["claim_id"],
      error.message
    )
    Rails.logger.error(response.message)
  end

  private

  # :reek:UtilityFunction
  def retrieve_max_errors_for_failure
    ENV["MAX_ERRORS_FOR_FAILURE"].to_i
  end
end
