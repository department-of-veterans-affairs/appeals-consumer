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
    "informal_conference_requested" => [TrueClass, FalseClass],
    "informal_conference_tracked_item_id" => [String, NilClass],
    "same_station_review_requested" => [TrueClass, FalseClass],
    "claim_creation_time" => String,
    "actor_username" => [String, NilClass],
    "actor_station" => String,
    "actor_application" => [String, NilClass],
    "completion_time" => [String, NilClass],
    "remand_created" => [TrueClass, FalseClass],
    "auto_remand" => [TrueClass, FalseClass],
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

  private

  # Assigns attributes from the message_payload to defined keys
  def assign(message_payload)
    attribute_types.each_key do |attr|
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
    "decision_review_issue_id" => Integer,
    "contention_id" => [Integer, NilClass],
    "associated_caseflow_request_issue_id" => [Integer, NilClass],
    "unidentified" => [TrueClass, FalseClass],
    "prior_rating_decision_id" => [Integer, NilClass],
    "prior_non_rating_decision_id" => [Integer, NilClass],
    "prior_caseflow_decision_issue_id" => [Integer, NilClass],
    "prior_decision_text" => [String, NilClass],
    "prior_decision_type" => [String, NilClass],
    "prior_decision_source" => [String, NilClass],
    "prior_decision_notification_date" => [String, NilClass],
    "prior_decision_date" => [String, NilClass],
    "prior_decision_diagnostic_code" => [String, NilClass],
    "prior_decision_rating_percentage" => [String, NilClass],
    "prior_decision_rating_sn" => [String, NilClass],
    "eligible" => [TrueClass, FalseClass],
    "eligibility_result" => String,
    "time_override" => [TrueClass, FalseClass, NilClass],
    "time_override_reason" => [String, NilClass],
    "contested" => [TrueClass, FalseClass, NilClass],
    "soc_opt_in" => [TrueClass, FalseClass, NilClass],
    "legacy_appeal_id" => [String, NilClass],
    "legacy_appeal_issue_id" => [Integer, NilClass],
    "prior_decision_award_event_id" => [Integer, NilClass],
    "prior_decision_rating_profile_date" => [String, NilClass],
    "source_claim_id_for_remand" => [Integer, NilClass],
    "source_contention_id_for_remand" => [Integer, NilClass],
    "original_caseflow_request_issue_id" => [Integer, NilClass],
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

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_ISSUE_COMPLETED_ATTRIBUTES
  end

  private

  # Assigns attributes from issue_attrs to defined keys
  def assign(issue)
    attribute_types.each_key do |attr|
      instance_variable_set("@#{attr}", issue[attr])
    end
  end

  def create_decisions(decision)
    return if decision.nil?

    @decision = CompletedDecision.new(decision)
  end
end

# CompletedDecision represents an individual decision object from
# a decision_review_issues_completed's decision field
class CompletedDecision
  include MessagePayloadValidator

  DECISION_ATTRIBUTES = {
    "contention_id" => Integer,
    "disposition" => String,
    "dta_error_explanation" => [String, NilClass],
    "decision_source" => [String, NilClass],
    "category" => [String, NilClass],
    "decision_id" => [Integer, NilClass],
    "decision_text" => [String, NilClass],
    "award_event_id" => [Integer, NilClass],
    "rating_profile_date" => [String, NilClass],
    "decision_recorded_time" => String,
    "decision_finalized_time" => [String, NilClass]
  }.freeze

  DECISION_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When CompletedDecision.new(decision) is called, this method will validate message_payload
  # presence, attribute names and data types and assign the incoming attributes to defined keys
  def initialize(decision = {})
    validate(decision, self.class.name)
    assign(decision)
  end

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_ATTRIBUTES
  end

  private

  # Assigns attributes from issue_attrs to defined keys
  def assign(decision)
    attribute_types.each_key do |attr|
      instance_variable_set("@#{attr}", decision[attr])
    end
  end

  # Overwrites validate_presence method in MessagePayloadValidator because a
  # DecisionReviewCompleted CompletedDecision CAN be nil but not an empty hash
  def validate_presence(decision, class_name)
    if decision.blank?
      fail ArgumentError, "#{class_name}: Message payload cannot be empty"
    end
  end
end