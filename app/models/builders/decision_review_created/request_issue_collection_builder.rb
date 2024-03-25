# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues
class Builders::DecisionReviewCreated::RequestIssueCollectionBuilder
  # issues with this eligibility_result are not included in the caseflow payload
  # caseflow does not track or have a concept of this when determining ineligible_reason
  CONTESTED = "CONTESTED"

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.build_issues
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
  end

  # valid_issues are the decision_review_issues that don't have "CONTESTED" eligibility_result
  def build_issues
    valid_issues.map.with_index do |issue, index|
      build_request_issue(issue, index)
    end
  end

  private

  # exception thrown if there aren't any issues after removing issues with "CONTESTED" eligibility_result
  def valid_issues
    valid_issues = remove_ineligible_contested_issues
    handle_no_issues_after_removing_contested if valid_issues.empty?

    valid_issues
  end

  def remove_ineligible_contested_issues
    @decision_review_created.decision_review_issues.reject { |issue| issue.eligibility_result == CONTESTED }
  end

  def handle_no_issues_after_removing_contested
    fail AppealsConsumer::Error::RequestIssueCollectionBuildError, "Failed building from"\
      " Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for DecisionReviewCreated Claim ID:"\
      " #{@decision_review_created.claim_id} does not contain any valid issues after"\
      " removing 'CONTESTED' ineligible issues"
  end

  # index is only used as an identifier if the decision_review_issue's contention_id is nil
  def build_request_issue(issue, index)
    begin
      # RequestIssueBuilder needs access to a few attributes within @decision_review_created
      Builders::DecisionReviewCreated::RequestIssueBuilder.build(issue, @decision_review_created)
    rescue StandardError => error
      message = "Failed building from Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for "\
      "DecisionReviewCreated Claim ID: #{@decision_review_created.claim_id} "\
      "#{issue_identifier_message(issue, index)} - #{error.message}"

      # TODO: make sure this is notified in sentry/slack
      raise AppealsConsumer::Error::RequestIssueBuildError, message
    end
  end

  # in cases where the decision review issue has null for contention_id, use the index of the issue as the identifier
  def issue_identifier_message(issue, index)
    (!!issue.contention_id) ? "Issue Contention ID: #{issue.contention_id}" : "Issue Index: #{index}"
  end
end
