# frozen_string_literal: true

# This class is the parent class for different Kafka topic events. We use STI here.
# Represents a single "event", and is tied to "event audits" that contain info regarding
# information on operations regarding this event (e.g. POSTing DecisionReviewCreated event info to Caseflow)
class Event < ApplicationRecord
  has_many :event_audits

  validates :type, presence: true
  validates :message_payload, presence: true

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

  private

  # :reek:UtilityFunction
  def retrieve_max_errors_for_failure
    ENV["MAX_ERRORS_FOR_FAILURE"].to_i
  end
end
