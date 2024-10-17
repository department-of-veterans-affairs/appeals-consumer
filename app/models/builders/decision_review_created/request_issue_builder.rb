# frozen_string_literal: true

# This class is used to build out an individual Request Issue from decision_review_model.decision_review_issues
class Builders::DecisionReviewCreated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  attr_reader :decision_review_model, :issue, :request_issue

  def initialize(issue, decision_review_model, bis_rating_profiles)
    @request_issue = DecisionReviewCreated::RequestIssue.new
    super(issue, decision_review_model, bis_rating_profiles, @request_issue)
  end

  # ineligible issues are closed upon creation
  def calculate_closed_at
    @request_issue.closed_at = ineligible? ? claim_creation_time_converted_to_timestamp_ms : nil
  end

  # only populated for eligible rating issues
  def calculate_rating_issue_associated_at
    @request_issue.rating_issue_associated_at =
      if rating? && eligible?
        claim_creation_time_converted_to_timestamp_ms
      end
  end
end
