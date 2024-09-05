# frozen_string_literal: true

# a Request Issue Collection Builder specifically for ineligible to ineligible issues
# by using the reason_for_contention_action and the contention_action from the event message_payload
# this collects the issue and assigns it to the ineligible_to_ineligibles_issues payload for the dto builder.
class Builders::DecisionReviewUpdated::IneligibleToIneligibleIssueCollectionBuilder <
   Builders::BaseRequestIssueCollectionBuilder
  def build_issues
    ineligible_to_ineligible_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  def build_request_issue(issue, index)
    begin
      Builders::DecisionReviewUpdated::RequestIssueBuilder.build(issue, @decision_review_model, @bis_rating_profiles)
    rescue StandardError => error
      message = "Failed building ineligible_to_ineligible issue from #{self.class} for DecisionReview Claim ID:" \
      "#{@decision_review_model.claim_id} #{issue_identifier_message(issue, index)} - #{error.message}"

      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  # selects issues inside the decision_review_issues_updated message_payload
  # ENUMs ineligible_reason_changed & contention_none are defined in the base_request_issue_collection_builder
  def ineligible_to_ineligible_issues
    @decision_review_model.decision_review_issues_updated.select do |issue|
      issue.reason_for_contention_action == ineligible_reason_changed && issue.contention_action == no_contention_action
    end
  end
end
