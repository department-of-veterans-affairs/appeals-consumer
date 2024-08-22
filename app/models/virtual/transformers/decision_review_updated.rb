# frozen_string_literal: true

# DecisionReviewUpdated represents the message_payload from an individual DecisionReviewUpdatedEvent
class Transformers::DecisionReviewUpdated
  include MessagePayloadValidator

  attr_reader :event_id

  # Lists the attributes and corresponding data types
  # Data types are listed in an array when the value isn't limited to one data type
  # For example, originated_from_vacols_issue could be a boolean OR nil
  DECISION_REVIEW_UPDATED_ATTRIBUTES = {
    "claim_id" => Integer,
    "original_source" => String,
    "decision_review_type" => [String, NilClass],
    "veteran_first_name" => String,
    "veteran_last_name" => String,
    "veteran_participant_id" => String,
    "file_number" => String,
    "claimant_participant_id" => String,
    "ep_code" => String,
    "ep_code_category" => String,
    "claim_received_date" => String,
    "claim_lifecycle_status" => String,
    "payee_code" => String,
    "modifier" => String,
    "originated_from_vacols_issue" => [TrueClass, FalseClass, NilClass],
    "limited_poa_code" => [String, NilClass],
    "tracked_item_action" => String,
    "informal_conference_requested" => [TrueClass, FalseClass],
    "informal_conference_tracked_item_id" => [String, NilClass],
    "same_station_review_requested" => [TrueClass, FalseClass],
    "update_time" => String,
    "claim_creation_time" => String,
    "actor_username" => String,
    "actor_station" => String,
    "actor_application" => String,
    "auto_remand" => [TrueClass, FalseClass],
    "decision_review_issues_created" => Array,
    "decision_review_issues_updated" => Array,
    "decision_review_issues_removed" => Array,
    "decision_review_issues_withdrawn" => Array,
    "decision_review_issues_not_changed" => Array,
  }.freeze
  # Allows read and write access for attributes
  DECISION_REVIEW_UPDATED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewUpdated.new(message_payload) is called, this method will validate message_payload
  # presence, attribute names and data types, assign the incoming attributes to defined keys,
  # and create DecisionReviewIssueUpdated instances for each object in message_payload's decision_review_issues array
  def initialize(event_id, message_payload)
    @event_id = event_id
    validate(message_payload, self.class.name)
    assign(message_payload)
    create_decision_review_issues(message_payload)
  end

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_UPDATED_ATTRIBUTES
  end

  # Assigns attributes from the message_payload to defined keys
  def assign(message_payload)
    DECISION_REVIEW_UPDATED_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", message_payload[attr])
    end
  end

  # Creates instances of DecisionReviewIssueUpdated, validates attributes, and assigns attributes
  # for each object in the decision_review_issues array
  # Fails out of workflow if decision_review_issues is an empty array
  def create_decision_review_issues(payload)
    if payload_invalid?(payload)
      fail ArgumentError, "#{self.class.name}: Message payload must include at least one decision review issue updated"
    end

    issues = payload.slice(
      "decision_review_issues_created",
      "decision_review_issues_updated",
      "decision_review_issues_removed",
      "decision_review_issues_withdrawn",
      "decision_review_issues_not_changed"
    )

    issues.each do |key, values|
      instance_variable_set("@#{key}", values.map { |issue| DecisionReviewIssueUpdated.new(issue) })
    end
  end

  def payload_invalid?(payload)
    payload["decision_review_issues_created"].blank? &&
      payload["decision_review_issues_updated"].blank? &&
      payload["decision_review_issues_removed"].blank? &&
      payload["decision_review_issues_withdrawn"].blank?
  end
end

# DecisionReviewIssueUpdated represents an individual issue object from the message_payload's
# decision_review_issues_created, decision_review_issues_updated, decision_review_issues_removed,
# or decision_review_issues_withdrawn arrays
class DecisionReviewIssueUpdated
  include MessagePayloadValidator

  # Lists the attributes and corresponding data types
  # Data types are stored in an array when the value isn't limited to one data type
  # For example, time_override could be a boolean OR nil
  DECISION_REVIEW_ISSUE_UPDATED_ATTRIBUTES = {
    "decision_review_issue_id" => [Integer, NilClass],
    "contention_id" => [Integer, NilClass],
    "contention_action" => String,
    "reason_for_contention_action" => String,
    "associated_caseflow_request_issue_id" => [Integer, NilClass],
    "unidentified" => [TrueClass, FalseClass],
    "prior_rating_decision_id" => [Integer, NilClass],
    "prior_non_rating_decision_id" => [Integer, NilClass],
    "prior_caseflow_decision_issue_id" => [Integer, NilClass],
    "prior_decision_text" => [String, NilClass],
    "prior_decision_type" => [String, NilClass],
    "prior_decision_source" => [String, NilClass],
    "prior_decision_notification_date" => [Date, NilClass],
    "prior_decision_date" => [Date, NilClass],
    "prior_decision_diagnostic_code" => [String, NilClass],
    "prior_decision_rating_percentage" => [String, NilClass],
    "prior_decision_rating_sn" => [String, NilClass],
    "eligible" => [TrueClass, FalseClass],
    "eligibility_result" => String,
    "time_override" => [TrueClass, FalseClass, NilClass],
    "time_override_reason" => [String, NilClass],
    "contested" => [TrueClass, FalseClass, NilClass],
    "soc_opt_in" => [TrueClass, FalseClass, NilClass],
    "legacy_appeal_id" => [Integer, NilClass],
    "legacy_appeal_issue_id" => [Integer, NilClass],
    "prior_decision_award_event_id" => [Integer, NilClass],
    "prior_decision_rating_profile_date" => [String, NilClass],
    "source_claim_id_for_remand" => [Integer, NilClass],
    "source_contention_id_for_remand" => [Integer, NilClass],
    "removed" => [TrueClass, FalseClass],
    "withdrawn" => [TrueClass, FalseClass],
    "decision" => [Hash, NilClass]
  }.freeze
  # Allows read and write access for attributes
  DECISION_REVIEW_ISSUE_UPDATED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewIssueUpdated.new(issue_attrs) is called, this method will validate message_payload
  # presence, attribute names and data types and assign the incoming attributes to defined keys
  def initialize(issue = {})
    validate(issue, self.class.name)
    assign(issue)
    create_decisions(issue["decision"])
  end

  private

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_ISSUE_UPDATED_ATTRIBUTES
  end

  # Assigns attributes from issue_attrs to defined keys
  def assign(issue)
    DECISION_REVIEW_ISSUE_UPDATED_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", issue[attr])
    end
  end

  def create_decisions(decision)
    return if decision.blank?

    @decision = Decision.new(decision)
  end
end

class Decision
  include MessagePayloadValidator

  DECISION_ATTRIBUTES = {
    "contention_id" => Integer,
    "disposition" => String,
    "dta_error_explanation" => String,
    "decision_source" => String,
    "category" => String,
    "decision_id" => Integer,
    "decision_text" => String,
    "award_event_id" => Integer,
    "rating_profile_date" => String,
    "decision_recorded_time" => String,
    "decision_finalized_time" => String
  }.freeze

  DECISION_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  def initialize(decision = {})
    validate(decision, self.class.name)
    assign(decision)
  end

  private

  def attribute_types
    DECISION_ATTRIBUTES
  end

  def assign(decision)
    DECISION_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", decision[attr])
    end
  end
end