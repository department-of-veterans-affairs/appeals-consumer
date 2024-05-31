# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCompleted::RequestIssueBuilder
class DecisionReviewCreated::RequestIssue
  attr_accessor :closed_at, :closed_status, :contention_reference_id, :decision_sync_attempted_at,
                :decision_sync_processed_at, :vacols_id, :vacols_sequence_id
end