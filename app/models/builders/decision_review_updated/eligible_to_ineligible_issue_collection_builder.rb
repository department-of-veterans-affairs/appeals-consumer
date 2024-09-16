# frozen_string_literal: true

class Builders::DecisionReviewUpdated::EligibleToIneligibleIssueCollectionBuilder <
      Builders::BaseRequestIssueCollectionBuilder
  # valid_issues are the decision_review_issues that don't have "CONTESTED" eligibility_result
  def build_issues
    eligible_to_ineligible_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  # index is only used as an identifier if the decision_review_issue's contention_id is nil
  def build_request_issue(issue, index)
    begin
      # RequestIssueBuilder needs access to a few attributes within @decision_review_model
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building eligible_to_ineligible_issues from #{self.class} for "\
      "DecisionReview Claim ID: #{@decision_review_model.claim_id} "\
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  # Check for specific criteria for issue eligibility
  def eligible_to_ineligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == eligible_to_ineligible && issue.contention_action == contention_deleted
    end
  end
end
