# frozen_string_literal: true

# This class is used to build out an individual Request Issue from decision_review_model.decision_review_issues
class Builders::DecisionReviewCreated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  attr_reader :decision_review_model, :issue, :request_issue

  def initialize(issue, decision_review_model, bis_rating_profiles)
    @request_issue = DecisionReviewCreated::RequestIssue.new
    super(issue, decision_review_model, bis_rating_profiles, @request_issue)
  end
end
