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

  def calculate_methods
    calculate_edited_description
    super
  end

  def assign_decision_review_issue_id
    @request_issue.decision_review_issue_id = issue.decision_review_issue_id
  end

  def calculate_closed_at
    closed_at_value = nil
    if ineligible? || withdrawn? || removed?
      closed_at_value = update_time_converted_to_timestamp_ms
    end
    @request_issue.closed_at = closed_at_value
  end

  # only populated for eligible rating issues
  def calculate_rating_issue_associated_at
    @request_issue.rating_issue_associated_at =
      if rating? && eligible?
        update_time_converted_to_timestamp_ms
      end
  end

  def calculate_edited_description
    if edited_description?
      @request_issue.edited_description = issue.prior_decision_text
    end
  end
end
