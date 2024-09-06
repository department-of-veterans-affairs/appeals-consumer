# frozen_string_literal: true

class Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    added_issues = newly_added_eligible_issues + newly_added_ineligible_issues

    added_issues.map.with_index do |issue, index|
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

  def newly_added_eligible_issues
    @decision_review_model.decision_review_issues_created.select do |issue|
      issue.reason_for_contention_action == new_eligible_issue && issue.contention_action == contention_added
    end
  end

  def newly_added_ineligible_issues
    @decision_review_model.decision_review_issues_created.select do |issue|
      issue.reason_for_contention_action == no_changes && issue.contention_action == contention_none
    end
  end
end
