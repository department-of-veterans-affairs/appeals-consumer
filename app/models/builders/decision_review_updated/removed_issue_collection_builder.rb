# frozen_string_literal: true

class Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder < 
  Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder

  def removed_issues
    @decision_review_model.decision_review_issues_removed.select do |issue|
      issue.reason_for_contention_action == removed && issue.contention_action == contention_deleted
    end
  end

  private

  def issues
    @issues ||= removed_issues
  end
end
