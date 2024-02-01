# frozen_string_literal: true

# This class is used to build out an array of Request Issues from decision_review_created.decision_review_issues
class Builders::RequestIssueBuilder
  attr_reader :request_issue

  def self.build(decision_review_issues)
    issues = []
    decision_review_issues.each do |issue|
      builder = new
      builder.assign_attributes(issue)
      issues << builder.request_issue
    end
    issues
  end

  def initialize
    @request_issue = RequestIssue.new
  end

  # rubocop:disable Metrics/MethodLength
  def assign_attributes(issue)
    calculate_benefit_type(issue)
    calculate_contested_issue_description(issue)
    assign_contention_reference_id(issue)
    assign_contested_rating_decision_reference_id(issue)
    assign_contested_rating_issue_profile_date(issue)
    assign_contested_rating_issue_reference_id(issue)
    assign_contested_decision_issue_id(issue)
    assign_decision_date(issue)
    calculate_ineligible_due_to_id(issue)
    calculate_ineligible_reason(issue)
    assign_is_unidentified(issue)
    calculate_unidentified_issue_text(issue)
    calculate_nonrating_issue_category(issue)
    calculate_nonrating_issue_description(issue)
    assign_untimely_exemption(issue)
    assign_untimely_exemption_notes(issue)
    assign_vacols_id(issue)
    assign_vacols_sequence_id(issue)
    calculate_closed_at(issue)
    calculate_closed_status(issue)
    assign_contested_rating_issue_diagnostic_code(issue)
    calculate_ramp_claim_id(issue)
    calculate_rating_issue_associated_at(issue)
    calculate_type(issue)
    assign_nonrating_issue_bgs_id(issue)
  end
  # rubocop:enable Metrics/MethodLength

  private

  def calculate_benefit_type(issue); end

  def calculate_contested_issue_description(issue); end

  def assign_contention_reference_id(issue); end

  def assign_contested_rating_decision_reference_id(issue); end

  def assign_contested_rating_issue_profile_date(issue); end

  def assign_contested_rating_issue_reference_id(issue); end

  def assign_contested_decision_issue_id(issue); end

  def assign_decision_date(issue); end

  def calculate_ineligible_due_to_id(issue); end

  def calculate_ineligible_reason(issue); end

  def assign_is_unidentified(issue); end

  def calculate_unidentified_issue_text(issue); end

  def calculate_nonrating_issue_category(issue); end

  def calculate_nonrating_issue_description(issue); end

  def assign_untimely_exemption(issue); end

  def assign_untimely_exemption_notes(issue); end

  def assign_vacols_id(issue); end

  def assign_vacols_sequence_id(issue); end

  def calculate_closed_at(issue); end

  def calculate_closed_status(issue); end

  def assign_contested_rating_issue_diagnostic_code(issue); end

  def calculate_ramp_claim_id(issue); end

  def calculate_rating_issue_associated_at(issue); end

  def calculate_type(issue); end

  def assign_nonrating_issue_bgs_id(issue); end
end
