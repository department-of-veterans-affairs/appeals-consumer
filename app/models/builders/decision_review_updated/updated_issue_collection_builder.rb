# frozen_string_literal: true

# a Request Issue Collection Builder specifically for updated issues
# by using the reason_for_contention_action and the contention_action from the event message_payload
# this collects the issue and assigns it to the updated_issues payload for the dto builder.
class Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder <
  Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  # selects issues inside the decision_review_issues_updated message_payload
  # ENUMs text_changed & contention_updated and contention_none
  # are defined in the base_request_issue_collection_builder
  def updated_issues
    updated_issues_with_contentions + updated_issues_without_contentions
  end

  private

  def updated_issues_with_contentions
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == text_changed && issue.contention_action == contention_updated
    end
  end

  def updated_issues_without_contentions
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == text_changed && issue.contention_action == no_contention_action
    end
  end

  def issues
    updated_issues
  end
end
