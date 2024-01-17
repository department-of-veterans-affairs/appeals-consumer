# frozen_string_literal: true

require_relative "./concerns/attribute_validator"

# DecisionReviewCreated represents the entire message_payload from an individual DecisionReviewCreatedEvent
class DecisionReviewCreated
  include AttributeValidator

  attr_accessor :claim_id, :decision_review_type, :veteran_first_name, :veteran_last_name, :veteran_participant_id,
                :veteran_file_number, :claimant_participant_id, :ep_code, :ep_code_category, :claim_received_date,
                :claim_lifecycle_status, :payee_code, :modifier, :originated_from_vacols_issue,
                :informal_conference_requested, :same_station_requested, :intake_creation_time, :claim_creation_time,
                :created_by_username, :created_by_station, :created_by_application, :decision_review_issues

  # When DecisionReviewCreated.new(message_payload) is called, this method will
  # validate the attribute names and data types, assign the incoming attributes to defined keys, and
  # create DecisionReviewIssue instances for each object in the message_payload's decision_review_issues array
  def initialize(attributes = {})
    validate(attributes)
    assign(attributes)
    extract_decision_review_issues(attributes[:decision_review_issues])
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # Lists the attributes and corresponding data types
  # Data types are listed in an array when the value isn't limited to one data type
  # For example, originated_from_vacols_issue could be a boolean OR nil
  def attribute_types
    {
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
  end

  # Assigns attributes from the message_payload to defined keys
  def assign(attributes)
    @claim_id = attributes[:claim_id]
    @decision_review_type = attributes[:decision_review_type]
    @veteran_first_name = attributes[:veteran_first_name]
    @veteran_last_name = attributes[:veteran_last_name]
    @veteran_participant_id = attributes[:veteran_participant_id]
    @veteran_file_number = attributes[:veteran_file_number]
    @claimant_participant_id = attributes[:claimant_participant_id]
    @ep_code = attributes[:ep_code]
    @ep_code_category = attributes[:ep_code_category]
    @claim_received_date = attributes[:claim_received_date]
    @claim_lifecycle_status = attributes[:claim_lifecycle_status]
    @payee_code = attributes[:payee_code]
    @modifier = attributes[:modifier]
    @originated_from_vacols_issue = attributes[:originated_from_vacols_issue]
    @informal_conference_requested = attributes[:informal_conference_requested]
    @same_station_requested = attributes[:same_station_requested]
    @intake_creation_time = attributes[:intake_creation_time]
    @claim_creation_time = attributes[:claim_creation_time]
    @created_by_username = attributes[:created_by_username]
    @created_by_station = attributes[:created_by_station]
    @created_by_application = attributes[:created_by_application]
    @decision_review_issues = attributes[:decision_review_issues]
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Creates instances of DecisionReviewIssue, validates attributes, and assigns attributes
  # for each object in the decision_review_issues array
  def extract_decision_review_issues(decision_review_issues)
    decision_review_issues&.map { |issue_attributes| DecisionReviewIssue.new(issue_attributes) }
  end
end

# DecisionReviewIssue represents an individual issue object from the message_payload's decision_review_issues array
class DecisionReviewIssue
  include AttributeValidator

  attr_reader :contention_id, :associated_caseflow_request_issue_id, :unidentified, :prior_rating_decision_id,
              :prior_non_rating_decision_id, :prior_decision_text, :prior_decision_type,
              :prior_decision_notification_date, :prior_decision_diagnostic_code, :prior_decision_rating_percentage,
              :eligible, :eligibility_result, :time_override, :time_override_reason, :contested, :soc_opt_in,
              :legacy_appeal_id, :legacy_appeal_issue_id

  # When DecisionReviewIssue.new(issue_attributes) is called, this method will
  # validate the attribute names and data types and assign the incoming attributes to defined keys
  def initialize(attributes = {})
    validate(attributes)
    assign(attributes)
  end

  private

  # Lists the attributes and corresponding data types
  # Data types are listed in an array when the value isn't limited to one data type
  # For example, time_override could be a boolean OR nil
  def attribute_types
    {
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
  end

  # Assigns attributes from issue_attributes to defined keys
  def assign(attributes)
    @contention_id = attributes[:contention_id]
    @associated_caseflow_request_issue_id = attributes[:associated_caseflow_request_issue_id]
    @unidentified = attributes[:unidentified]
    @prior_rating_decision_id = attributes[:prior_rating_decision_id]
    @prior_non_rating_decision_id = attributes[:prior_non_rating_decision_id]
    @prior_decision_text = attributes[:prior_decision_text]
    @prior_decision_type = attributes[:prior_decision_type]
    @prior_decision_notification_date = attributes[:prior_decision_notification_date]
    @prior_decision_diagnostic_code = attributes[:prior_decision_diagnostic_code]
    @prior_decision_rating_percentage = attributes[:prior_decision_rating_percentage]
    @eligible = attributes[:eligible]
    @eligibility_result = attributes[:eligibility_result]
    @time_override = attributes[:time_override]
    @time_override_reason = attributes[:time_override_reason]
    @contested = attributes[:contested]
    @soc_opt_in = attributes[:soc_opt_in]
    @legacy_appeal_id = attributes[:legacy_appeal_id]
    @legacy_appeal_issue_id = attributes[:legacy_appeal_issue_id]
  end
end
