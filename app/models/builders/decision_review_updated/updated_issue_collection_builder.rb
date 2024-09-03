# frozen_string_literal: true

class Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    updated_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  def build_request_issue(issue, index)
    begin
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building from #{self.class} for DecisionReview Claim ID: #{@decision_review_model.claim_id} " \
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  def updated_issues
    update_contention_issues + contention_action_none_issues
  end

  # rubocop:disable Layout/LineLength
  def update_contention_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == "PRIOR_DECISION_TEXT_CHANGED" && issue.contention_action == "UPDATE_CONTENTION"
    end
  end
  # rubocop:enable Layout/LineLength

  def contention_action_none_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == "PRIOR_DECISION_TEXT_CHANGED" && issue.contention_action == "NONE"
    end
  end
end
