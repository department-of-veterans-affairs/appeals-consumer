# frozen_string_literal: true

class Builders::DecisionReviewUpdated::WithdrawnIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    withdrawn_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  def build_request_issue(issue, index)
    begin
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building withdrawn_issues from #{self.class} for "\
      "DecisionReview Claim ID: #{@decision_review_model.claim_id} "\
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  def withdrawn_issues
    @decision_review_model.decision_review_issues_withdrawn.select do |issue|
      issue.reason_for_contention_action == withdrawn && issue.contention_action == contention_deleted
    end
  end
end
