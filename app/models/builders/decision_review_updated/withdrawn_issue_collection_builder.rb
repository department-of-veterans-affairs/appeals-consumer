# frozen_string_literal: true

class Builders::DecisionReviewUpdated::WithdrawnIssueCollectionBuilder <
  Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  def withdrawn_issues
    @decision_review_model.decision_review_issues_withdrawn.select do |issue|
      issue.reason_for_contention_action == withdrawn && issue.contention_action == contention_deleted
    end
  end

  private

  def issues
    @issues ||= withdrawn_issues
  end
end
