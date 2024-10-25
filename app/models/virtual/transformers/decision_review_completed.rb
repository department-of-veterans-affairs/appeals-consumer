# frozen_string_literal: true

# DecisionReviewCompleted represents the message_payload from an individual DecisionReviewCompletedEvent
class Transformers::DecisionReviewCompleted
  include MessagePayloadValidator

  attr_reader :event_id

  # Lists the attributes and corresponding data types
  # Data types are listed in an array when the value isn't limited to one data type
  # For example, remand_created could be a boolean OR nil
  DECISION_REVIEW_COMPLETED_ATTRIBUTES = {
    "claim_id" => Integer,
    "decision_review_type" => [String, NilClass],
    "veteran_participant_id" => String,
    "claimant_participant_id" => String,
    "remand_created" => [TrueClass, FalseClass, NilClass],
    "ep_code_category" => String,
    "claim_lifecycle_status" => String,
    "actor_username" => String,
    "actor_application" => String,
    "completion_time" => String,
    "decision_review_issues_completed" => Array
  }.freeze
  # Allows read and write access for attributes
  DECISION_REVIEW_COMPLETED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewCompleted.new(message_payload) is called, this method will validate message_payload
  # presence, attribute names and data types, assign the incoming attributes to defined keys,
  # and create DecisionReviewIssueCompleted instances for each object in
  # message_payload's decision_review_issues_completed array
  def initialize(event_id, message_payload)
    @event_id = event_id
    validate(message_payload, self.class.name)
    assign(message_payload)
  end

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_COMPLETED_ATTRIBUTES
  end

  # Assigns attributes from the message_payload to defined keys
  def assign(message_payload)
    DECISION_REVIEW_COMPLETED_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", message_payload[attr])
    end

    decision_review_issues_completed_array = message_payload["decision_review_issues_completed"]
    @decision_review_issues_completed = create_decision_review_issues_completed(decision_review_issues_completed_array)
  end

  # Creates instances of DecisionReviewIssueCompleted, validates attributes, and assigns attributes
  # for each object in the decision_review_issues_completed array
  # Fails out of workflow if decision_review_issues_completed is an empty array
  def create_decision_review_issues_completed(decision_review_issues_completed)
    if decision_review_issues_completed.blank?
      fail ArgumentError,
           "#{self.class.name}: Message payload must include at least one decision review issue completed"
    end

    decision_review_issues_completed.map { |issue| DecisionReviewIssueCompleted.new(issue) }
  end
end

# DecisionReviewIssueCompleted represents an individual issue
# object from the message_payload's decision_review_issues_completed
class DecisionReviewIssueCompleted
  include MessagePayloadValidator

  # Lists the attributes and corresponding data types
  # Data types are stored in an array when the value isn't limited to one data type
  # For example, soc_opt_in could be a boolean OR nil
  DECISION_REVIEW_ISSUE_COMPLETED_ATTRIBUTES = {
    "decision_review_issue_id" => [Integer],
    "contention_id" => [Integer, NilClass],
    "remand_claim_id" => [String, NilClass],
    "remand_contention_id" => [String, NilClass],
    "unidentified" => [TrueClass, FalseClass],
    "prior_rating_decision_id" => [Integer, NilClass],
    "prior_non_rating_decision_id" => [Integer, NilClass],
    "prior_caseflow_decision_issue_id" => [Integer, NilClass],
    "prior_decision_rating_sn" => [String, NilClass],
    "prior_decision_text" => [String, NilClass],
    "prior_decision_type" => [String, NilClass],
    "prior_decision_source" => [String, NilClass],
    "prior_decision_notification_date" => [String, NilClass],
    "legacy_appeal_issue_id" => [Integer, NilClass],
    "prior_decision_rating_profile_date" => [String, NilClass],
    "soc_opt_in" => [TrueClass, FalseClass, NilClass],
    "legacy_appeal_id" => [String, NilClass],
    "decision" => [Hash, NilClass]
  }.freeze
  # Allows read and write access for attributes
  DECISION_REVIEW_ISSUE_COMPLETED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewIssueCompleted.new(issue_attrs) is called, this method will validate message_payload
  # presence, attribute names and data types and assign the incoming attributes to defined keys
  def initialize(issue = {})
    validate(issue, self.class.name)
    assign(issue)
    create_decisions(issue["decision"])
  end

  private

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_ISSUE_COMPLETED_ATTRIBUTES
  end

  # Assigns attributes from issue_attrs to defined keys
  def assign(issue)
    DECISION_REVIEW_ISSUE_COMPLETED_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", issue[attr])
    end
  end

  def create_decisions(decision)
    return if decision.nil?

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

  def validate_presence(decision, class_name)
    if decision.blank?
      fail ArgumentError, "#{class_name}: Message payload cannot be empty"
    end
  end
end
