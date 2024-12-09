# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCreated::RequestIssueBuilder
class DecisionReviewCreated::RequestIssue < BaseRequestIssue
  attr_accessor :source_claim_id_for_remand, :source_contention_id_for_remand
end
