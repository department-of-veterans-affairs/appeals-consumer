# frozen_string_literal: true

class Builders::BaseRequestIssueCollectionBuilder
  include DecisionReview::ModelBuilderHelper
  # issues with this eligibility_result are not included in the caseflow payload
  # caseflow does not track or have a concept of this when determining ineligible_reason
  CONTESTED = "CONTESTED"
  RATING = "RATING"

  REASON_FOR_CONTENTION_ACTIONS = {
    INELIGIBLE_REASON_CHANGED: "INELIGIBLE_REASON_CHANGED",
    ISSUE_REMOVED: "REMOVED_SELECTED",
    ISSUE_WITHDRAWN: "WITHDRAWN_SELECTED"
  }.freeze

  CONTENTION_ACTIONS = {
    CONTENTION_DELETED: "DELETE_CONTENTION",
    NO_CONTENTION_ACTION: "NONE"
  }.freeze

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.build_issues
  end

  # only fetch BIS rating profiles if there are rating issues
  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
    @bis_rating_profiles = nil

    # only fetch and set BIS rating profiles if the message is rating and contains an identified BIS rating issue
    if message_has_rating_issues?
      initialize_issue_profile_dates
      fetch_and_set_bis_rating_profiles
    end
  end

  def build_issues
    fail NotImplementedError, "#{self.class} must implement the build_issues method"
  end

  # used to call BIS fetch_rating_profiles_in_range with specified date range
  # one day is added to the latest date incase a rating profile was added today
  def initialize_issue_profile_dates
    @earliest_issue_profile_date = earliest_issue_profile_date
    @latest_issue_profile_date_plus_one_day = latest_issue_profile_date_plus_one_day
  end

  # if issue profile date variables aren't nil,
  # fetch rating profiles from BIS and overwrite @bis_rating_profiles with response
  def fetch_and_set_bis_rating_profiles
    if @earliest_issue_profile_date && @latest_issue_profile_date_plus_one_day
      @bis_rating_profiles = fetch_bis_rating_profiles
    end
  end

  private

  # exception thrown if there aren't any issues after removing issues with "CONTESTED" eligibility_result
  def valid_issues
    valid_issues = remove_ineligible_contested_issues
    handle_no_issues_after_removing_contested if valid_issues.empty?

    valid_issues
  end

  def message_has_rating_issues?
    rating_ep_code_category? && at_least_one_valid_bis_issue?
  end

  def rating_ep_code_category?
    @decision_review_model.ep_code_category.upcase == RATING
  end

  def at_least_one_valid_bis_issue?
    valid_issues.any?(&:prior_rating_decision_id)
  end

  def remove_ineligible_contested_issues
    @decision_review_model.decision_review_issues.reject { |issue| issue.eligibility_result == CONTESTED }
  end

  def handle_no_issues_after_removing_contested
    fail AppealsConsumer::Error::RequestIssueCollectionBuildError, "Failed building from"\
      " #{self.class} for DecisionReview Claim ID:"\
      " #{@decision_review_model.claim_id} does not contain any valid issues after"\
      " removing 'CONTESTED' ineligible issues"
  end

  def build_request_issue(issue, index)
    fail NotImplementedError, "#{self.class} must implement the build__request_issue method"
  end

  # in cases where the decision review issue has null for contention_id, use the index of the issue as the identifier
  def issue_identifier_message(issue, index)
    (!!issue.contention_id) ? "Issue Contention ID: #{issue.contention_id}" : "Issue Index: #{index}"
  end

  def earliest_issue_profile_date
    valid_issue_profile_dates&.min
  end

  def latest_issue_profile_date
    valid_issue_profile_dates&.max
  end

  def latest_issue_profile_date_plus_one_day
    latest_issue_profile_date + 1 if !!latest_issue_profile_date
  end

  def valid_issue_profile_dates
    # no need to include invalid issue profile dates since they won't be included in the caseflow payload
    profile_dates = valid_issues.map(&:prior_decision_rating_profile_date)
    return nil if profile_dates.all?(&:nil?)

    # unidentified issues can have nil for this field, so remove nil values before mapping
    profile_dates.compact.map(&:to_date)
  end

  def removed
    REASON_FOR_CONTENTION_ACTIONS[:ISSUE_REMOVED]
  end

  def withdrawn
    REASON_FOR_CONTENTION_ACTIONS[:ISSUE_WITHDRAWN]
  end

  def contention_deleted
    CONTENTION_ACTIONS[:CONTENTION_DELETED]
  end

  def no_contention_action
    CONTENTION_ACTIONS[:NO_CONTENTION_ACTION]
  end

  def ineligible_reason_changed
    REASON_FOR_CONTENTION_ACTIONS[:INELIGIBLE_REASON_CHANGED]
  end
end
