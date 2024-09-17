# frozen_string_literal: true

class Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder < Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  def newly_added_eligible_issues
    @decision_review_model.decision_review_issues_created.select do |issue|
      issue.reason_for_contention_action == issue_added && issue.contention_action == contention_added
    end
  end

  def newly_added_ineligible_issues
    @decision_review_model.decision_review_issues_created.select do |issue|
      issue.reason_for_contention_action == no_changes && issue.contention_action == no_contention_action
    end
  end

  private

  def issues
    @issues ||= newly_added_eligible_issues + newly_added_ineligible_issues
  end
end
