# frozen_string_literal: true

# This class is used to build out an individual Request Issue from a DecisionReviewUpdated Event
class Builders::DecisionReviewUpdated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  attr_reader :decision_review_model, :issue, :request_issue

  def initialize(issue, decision_review_model, bis_rating_profiles)
    @request_issue = DecisionReviewUpdated::RequestIssue.new
    super(issue, decision_review_model, bis_rating_profiles, @request_issue)
  end

  def assign_methods
    assign_decision_review_issue_id
    super
  end

  def assign_decision_review_issue_id
    @request_issue.decision_review_issue_id = issue.decision_review_issue_id
  end

  def calculate_closed_at
    @request_issue.closed_at = ineligible? ? update_time_converted_to_timestamp_ms : nil
  end
end
