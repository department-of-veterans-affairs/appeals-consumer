# frozen_string_literal: true

require_relative "./concerns/message_payload_validator"

# DecisionReviewCreated represents the entire message_payload from an individual DecisionReviewCreatedEvent
class DecisionReviewCreated
  include MessagePayloadValidator

  attr_accessor :claim_id, :decision_review_type, :veteran_first_name, :veteran_last_name, :veteran_participant_id,
                :veteran_file_number, :claimant_participant_id, :ep_code, :ep_code_category, :claim_received_date,
                :claim_lifecycle_status, :payee_code, :modifier, :originated_from_vacols_issue,
                :informal_conference_requested, :same_station_requested, :intake_creation_time, :claim_creation_time,
                :created_by_username, :created_by_station, :created_by_application, :decision_review_issues

  # When DecisionReviewCreated.new(message_payload) is called, this method will
  # validate the attribute names and data types, assign the incoming attributes to defined keys, and
  # create DecisionReviewIssue instances for each object in the message_payload's decision_review_issues array
  def initialize(message_payload = {})
    validate(message_payload)
    assign(message_payload)
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
  def assign(message_payload)
    @claim_id = message_payload[:claim_id]
    @decision_review_type = message_payload[:decision_review_type]
    @veteran_first_name = message_payload[:veteran_first_name]
    @veteran_last_name = message_payload[:veteran_last_name]
    @veteran_participant_id = message_payload[:veteran_participant_id]
    @veteran_file_number = message_payload[:veteran_file_number]
    @claimant_participant_id = message_payload[:claimant_participant_id]
    @ep_code = message_payload[:ep_code]
    @ep_code_category = message_payload[:ep_code_category]
    @claim_received_date = message_payload[:claim_received_date]
    @claim_lifecycle_status = message_payload[:claim_lifecycle_status]
    @payee_code = message_payload[:payee_code]
    @modifier = message_payload[:modifier]
    @originated_from_vacols_issue = message_payload[:originated_from_vacols_issue]
    @informal_conference_requested = message_payload[:informal_conference_requested]
    @same_station_requested = message_payload[:same_station_requested]
    @intake_creation_time = message_payload[:intake_creation_time]
    @claim_creation_time = message_payload[:claim_creation_time]
    @created_by_username = message_payload[:created_by_username]
    @created_by_station = message_payload[:created_by_station]
    @created_by_application = message_payload[:created_by_application]
    @decision_review_issues = create_decision_review_issues(message_payload[:decision_review_issues])
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # Creates instances of DecisionReviewIssue, validates attributes, and assigns attributes
  # for each object in the decision_review_issues array
  def create_decision_review_issues(decision_review_issues)
    decision_review_issues&.map { |issue_attrs| DecisionReviewIssue.new(issue_attrs) }
  end
end

# DecisionReviewIssue represents an individual issue object from the message_payload's decision_review_issues array
class DecisionReviewIssue
  include MessagePayloadValidator

  attr_reader :contention_id, :associated_caseflow_request_issue_id, :unidentified, :prior_rating_decision_id,
              :prior_non_rating_decision_id, :prior_decision_text, :prior_decision_type,
              :prior_decision_notification_date, :prior_decision_diagnostic_code, :prior_decision_rating_percentage,
              :eligible, :eligibility_result, :time_override, :time_override_reason, :contested, :soc_opt_in,
              :legacy_appeal_id, :legacy_appeal_issue_id

  # When DecisionReviewIssue.new(issue_attrs) is called, this method will
  # validate the attribute names and data types and assign the incoming attributes to defined keys
  def initialize(message_payload = {})
    validate(message_payload)
    assign(message_payload)
  end

  private

  # Lists the attributes and corresponding data types
  # Data types are stored in an array when the value isn't limited to one data type
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

  # Assigns attributes from issue_attrs to defined keys
  def assign(message_payload)
    @contention_id = message_payload[:contention_id]
    @associated_caseflow_request_issue_id = message_payload[:associated_caseflow_request_issue_id]
    @unidentified = message_payload[:unidentified]
    @prior_rating_decision_id = message_payload[:prior_rating_decision_id]
    @prior_non_rating_decision_id = message_payload[:prior_non_rating_decision_id]
    @prior_decision_text = message_payload[:prior_decision_text]
    @prior_decision_type = message_payload[:prior_decision_type]
    @prior_decision_notification_date = message_payload[:prior_decision_notification_date]
    @prior_decision_diagnostic_code = message_payload[:prior_decision_diagnostic_code]
    @prior_decision_rating_percentage = message_payload[:prior_decision_rating_percentage]
    @eligible = message_payload[:eligible]
    @eligibility_result = message_payload[:eligibility_result]
    @time_override = message_payload[:time_override]
    @time_override_reason = message_payload[:time_override_reason]
    @contested = message_payload[:contested]
    @soc_opt_in = message_payload[:soc_opt_in]
    @legacy_appeal_id = message_payload[:legacy_appeal_id]
    @legacy_appeal_issue_id = message_payload[:legacy_appeal_issue_id]
  end
end
