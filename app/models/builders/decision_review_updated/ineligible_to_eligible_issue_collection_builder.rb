# frozen_string_literal: true

class Builders::DecisionReviewUpdated::IneligibleToEligibleIssueCollectionBuilder <
  Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  def ineligible_to_eligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == ineligible_to_eligible && issue.contention_action == contention_added
    end
  end

  private

  def issues
    @issues ||= ineligible_to_eligible_issues
  end
end
