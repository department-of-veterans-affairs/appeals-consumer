# frozen_string_literal: true

class Builders::DecisionReviewUpdated::EligibleToIneligibleIssueCollectionBuilder <
      Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  # Check for specific criteria for issue eligibility
  def eligible_to_ineligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == eligible_to_ineligible && issue.contention_action == contention_deleted
    end
  end
  
  private

  def issues
    @issues ||= eligible_to_ineligible_issues
  end
end
