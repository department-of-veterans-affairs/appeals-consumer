# frozen_string_literal: true

# This is tied to Event and contains info regarding operations related to Event.
#  (e.g. POSTing DecisionReviewCreated event info to Caseflow)
class EventAudit < ApplicationRecord
  belongs_to :event

  validates :event_id, presence: true
  validates :status, presence: true

  IN_PROGRESS = "IN_PROGRESS"
  COMPLETED = "COMPLETED"
  FAILED = "FAILED"

  enum status: {
    in_progress: IN_PROGRESS,
    completed: COMPLETED,
    failed: FAILED
  }

  def in_progress!
    update!(status: IN_PROGRESS)
  end

  def completed!
    update!(status: COMPLETED)
  end

  def failed!(error_message)
    update!(status: FAILED, error: error_message)
  end

  def started_at!
    update!(started_at: Time.zone.now)
  end

  def ended_at!
    update!(ended_at: Time.zone.now)
  end
end
