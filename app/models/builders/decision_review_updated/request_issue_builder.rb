# frozen_string_literal: true

# This class is used to build out an individual Request Issue from a DecisionReviewUpdated Event
class Builders::DecisionReviewUpdated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  attr_reader :decision_review_model, :issue, :request_issue

  def initialize(issue, decision_review_model, bis_rating_profiles)
    @request_issue = DecisionReviewCreated::RequestIssue.new
    super(issue, decision_review_model, bis_rating_profiles, @request_issue)
  end
end
