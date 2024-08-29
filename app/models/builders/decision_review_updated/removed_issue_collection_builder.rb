# frozen_string_literal: true

class Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder

  REMOVED_SELECTED = 'REMOVED_SELECTED'
  DELETE_CONTENTION = 'DELETE_CONTENTION'

  def build_issues
    removed_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  def build_request_issue(issue, index)
    begin
      # RequestIssueBuilder needs access to a few attributes within @decision_review_model
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building from #{self.class} for "\
      "DecisionReview Claim ID: #{@decision_review_model.claim_id} "\
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  private

  def removed_issues
    @decision_review_model.decision_review_issues_removed
    .select { 
      |issue| issue.reason_for_contention_action == REMOVED_SELECTED && issue.contention_action == DELETE_CONTENTION 
    }
  end
end
