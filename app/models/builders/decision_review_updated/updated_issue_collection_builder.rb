# frozen_string_literal: true

# a Request Issue Collection Builder specifically for updated issues
# by using the reason_for_contention_action and the contention_action from the event message_payload
# this collects the issue and assigns it to the updated_issues payload for the dto builder.
class Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder < Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    updated_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  def build_request_issue(issue, index)
    begin
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building updated_issues from #{self.class} for DecisionReview " \
      "Claim ID: #{@decision_review_model.claim_id} #{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  # selects issues inside the decision_review_issues_updated message_payload
  # ENUMs text_changed & contention_updated and contention_none
  # are defined in the base_request_issue_collection_builder
  def updated_issues
    updated_issues_with_contentions + updated_issues_without_contentions
  end

  def updated_issues_with_contentions
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == text_changed && issue.contention_action == contention_updated
    end
  end

  def updated_issues_without_contentions
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == text_changed && issue.contention_action == contention_none
    end
  end
end
