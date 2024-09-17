# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues_created
class Builders::DecisionReviewCreated::RequestIssueCollectionBuilder < Builders::BaseDecisionReviewCreatedRequestIssueCollectionBuilder
  private

  def issues
    @issues ||= @decision_review_model.decision_review_issues_created
  end
end
