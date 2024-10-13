# frozen_string_literal: true

class Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_request_issue(issue, index)
    begin
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building from #{self.class} for DecisionReview Claim ID: #{@decision_review_model.claim_id} " \
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end
end
