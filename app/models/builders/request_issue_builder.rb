# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues
class Builders::RequestIssueBuilder
  attr_reader :request_issue, :issue

  def self.build(decision_review_issues)
    issues = []
    decision_review_issues.each do |issue|
      builder = new(issue)
      builder.assign_attributes
      issues << builder.request_issue
    end
    issues
  end

  def initialize(issue)
    @issue = issue
    @request_issue = RequestIssue.new
  end

  # rubocop:disable Metrics/MethodLength
  def assign_attributes
    calculate_benefit_type
    calculate_contested_issue_description
    assign_contention_reference_id
    assign_contested_rating_decision_reference_id
    assign_contested_rating_issue_profile_date
    assign_contested_rating_issue_reference_id
    assign_contested_decision_issue_id
    assign_decision_date
    calculate_ineligible_due_to_id
    calculate_ineligible_reason
    assign_is_unidentified
    calculate_unidentified_issue_text
    calculate_nonrating_issue_category
    calculate_nonrating_issue_description
    assign_untimely_exemption
    assign_untimely_exemption_notes
    assign_vacols_id
    assign_vacols_sequence_id
    calculate_closed_at
    calculate_closed_status
    assign_contested_rating_issue_diagnostic_code
    calculate_ramp_claim_id
    calculate_rating_issue_associated_at
    calculate_type
    assign_nonrating_issue_bgs_id
  end
  # rubocop:enable Metrics/MethodLength

  private

  def calculate_benefit_type; end

  def calculate_contested_issue_description; end

  def assign_contention_reference_id; end

  def assign_contested_rating_decision_reference_id; end

  def assign_contested_rating_issue_profile_date; end

  def assign_contested_rating_issue_reference_id; end

  def assign_contested_decision_issue_id; end

  def assign_decision_date; end

  def calculate_ineligible_due_to_id; end

  def calculate_ineligible_reason; end

  def assign_is_unidentified; end

  def calculate_unidentified_issue_text; end

  def calculate_nonrating_issue_category; end

  def calculate_nonrating_issue_description; end

  def assign_untimely_exemption; end

  def assign_untimely_exemption_notes; end

  def assign_vacols_id; end

  def assign_vacols_sequence_id; end

  def calculate_closed_at; end

  def calculate_closed_status; end

  def assign_contested_rating_issue_diagnostic_code; end

  def calculate_ramp_claim_id; end

  def calculate_rating_issue_associated_at; end

  def calculate_type; end

  def assign_nonrating_issue_bgs_id; end
end
