# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues_created
class Builders::DecisionReviewCreated::RequestIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  # index is only used as an identifier if the decision_review_issue's contention_id is nil
  def build_request_issue(issue, index)
    begin
      # RequestIssueBuilder needs access to a few attributes within @decision_review_model
      Builders::DecisionReviewCreated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building from #{self.class} for "\
      "DecisionReview Claim ID: #{@decision_review_model.claim_id} "\
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end
end
