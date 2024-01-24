# frozen_string_literal: true

require_relative "./concerns/message_payload_validator"

# DecisionReviewCreated represents the message_payload from an individual DecisionReviewCreatedEvent
class DecisionReviewCreated
  include MessagePayloadValidator

  # Lists the attributes and corresponding data types
  # Data types are listed in an array when the value isn't limited to one data type
  # For example, originated_from_vacols_issue could be a boolean OR nil
  DECISION_REVIEW_CREATED_ATTRIBUTES = {
    claim_id: Integer,
    decision_review_type: [String, NilClass],
    veteran_first_name: String,
    veteran_last_name: String,
    veteran_participant_id: String,
    veteran_file_number: String,
    claimant_participant_id: String,
    ep_code: String,
    ep_code_category: String,
    claim_received_date: Date,
    claim_lifecycle_status: String,
    payee_code: String,
    modifier: String,
    originated_from_vacols_issue: [TrueClass, FalseClass, NilClass],
    informal_conference_requested: [TrueClass, FalseClass],
    same_station_requested: [TrueClass, FalseClass],
    intake_creation_time: Time,
    claim_creation_time: Time,
    created_by_username: String,
    created_by_station: String,
    created_by_application: String,
    decision_review_issues: Array
  }.freeze

  # Allows read and write access for attributes
  DECISION_REVIEW_CREATED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewCreated.new(message_payload) is called, this method will validate message_payload
  # presence, attribute names and data types, assign the incoming attributes to defined keys,
  # and create DecisionReviewIssue instances for each object in the message_payload's decision_review_issues array
  def initialize(message_payload = {})
    validate(message_payload, self.class.name)
    assign(message_payload)
  end

  private

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_CREATED_ATTRIBUTES
  end

  # Assigns attributes from the message_payload to defined keys
  def assign(message_payload)
    DECISION_REVIEW_CREATED_ATTRIBUTES.each { |attr, _| instance_variable_set("@#{attr}", message_payload[attr]) }

    decision_review_issues_array = message_payload[:decision_review_issues]
    @decision_review_issues = create_decision_review_issues(decision_review_issues_array)
  end

  # Creates instances of DecisionReviewIssue, validates attributes, and assigns attributes
  # for each object in the decision_review_issues array
  # Fails out of workflow if decision_review_issues is an empty array
  def create_decision_review_issues(decision_review_issues)
    if decision_review_issues.blank?
      fail ArgumentError, "#{self.class.name}: Message payload must include at least one decision review issue"
    end

    decision_review_issues.map { |issue| DecisionReviewIssue.new(issue) }
  end
end

# DecisionReviewIssue represents an individual issue object from the message_payload's decision_review_issues array
class DecisionReviewIssue
  include MessagePayloadValidator

  # Lists the attributes and corresponding data types
  # Data types are stored in an array when the value isn't limited to one data type
  # For example, time_override could be a boolean OR nil
  DECISION_REVIEW_ISSUE_ATTRIBUTES = {
    contention_id: [Integer, NilClass],
    associated_caseflow_request_issue_id: [Integer, NilClass],
    unidentified: [TrueClass, FalseClass],
    prior_rating_decision_id: [Integer, NilClass],
    prior_non_rating_decision_id: [Integer, NilClass],
    prior_decision_text: String,
    prior_decision_type: [String, NilClass],
    prior_decision_notification_date: Date,
    prior_decision_diagnostic_code: [String, NilClass],
    prior_decision_rating_percentage: [String, NilClass],
    eligible: [TrueClass, FalseClass],
    eligibility_result: String,
    time_override: [TrueClass, FalseClass, NilClass],
    time_override_reason: [String, NilClass],
    contested: [TrueClass, FalseClass, NilClass],
    soc_opt_in: [TrueClass, FalseClass, NilClass],
    legacy_appeal_id: [Integer, NilClass],
    legacy_appeal_issue_id: [Integer, NilClass]
  }.freeze

  # Allows read and write access for attributes
  DECISION_REVIEW_ISSUE_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When DecisionReviewIssue.new(issue_attrs) is called, this method will validate message_payload
  # presence, attribute names and data types and assign the incoming attributes to defined keys
  def initialize(issue = {})
    validate(issue, self.class.name)
    assign(issue)
  end

  private

  # Lists the attributes and corresponding data types
  def attribute_types
    DECISION_REVIEW_ISSUE_ATTRIBUTES
  end

  # Assigns attributes from issue_attrs to defined keys
  def assign(issue)
    DECISION_REVIEW_ISSUE_ATTRIBUTES.each { |attr, _| instance_variable_set("@#{attr}", issue[attr]) }
  end
end
