# frozen_string_literal: true

# This is tied to Event and contains info regarding operations related to Event.
#  (e.g. POSTing DecisionReviewCreated event info to Caseflow)
class EventAudit < ApplicationRecord
  belongs_to :event

  validates :event_id, presence: true
  validates :status, presence: true

  enum status: {
    not_started: "NOT_STARTED",
    in_progress: "IN_PROGRESS",
    processed: "PROCESSED",
    error: "ERROR",
    failed: "FAILED"
  }
end
