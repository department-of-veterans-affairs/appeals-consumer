# frozen_string_literal: true

# a Request Issue Collection Builder specifically for ineligible to ineligible issues
# by using the reason_for_contention_action and the contention_action from the event message_payload
# this collects the issue and assigns it to the ineligible_to_ineligibles_issues payload for the dto builder.
class Builders::DecisionReviewUpdated::IneligibleToIneligibleIssueCollectionBuilder <
  Builders::BaseDecisionReviewUpdatedRequestIssueCollectionBuilder
  # selects issues inside the decision_review_issues_updated message_payload
  def ineligible_to_ineligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == ineligible_reason_changed && issue.contention_action == no_contention_action
    end
  end

  private

  def issues
    ineligible_to_ineligible_issues
  end
end
