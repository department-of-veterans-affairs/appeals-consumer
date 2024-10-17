# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewUpdeted::RequestIssueBuilder
class DecisionReviewUpdated::RequestIssue < BaseRequestIssue
  attr_accessor :edited_description, :original_caseflow_request_issue_id
end
