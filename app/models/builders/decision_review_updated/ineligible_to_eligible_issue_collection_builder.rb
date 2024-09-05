# frozen_string_literal: true

class
Builders::DecisionReviewUpdated::IneligibleToEligibleIssueCollectionBuilder <
Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    ineligible_to_eligible_issues.map.with_index do |issue, index|
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

  def ineligible_to_eligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == "INELIGIBLE_TO_ELIGIBLE" && issue.contention_action == "ADD_CONTENTION"
    end
  end
end
