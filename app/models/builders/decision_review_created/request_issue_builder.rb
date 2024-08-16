# frozen_string_literal: true

# This class is used to build out an individual Request Issue from decision_review_model.decision_review_issues
class Builders::DecisionReviewCreated::RequestIssueBuilder < Builders::BaseRequestIssueBuilder
  attr_reader :decision_review_model, :issue, :request_issue

  # returns the DecisionReviewCreated::RequestIssue record with all attributes assigned
  def self.build(issue, decision_review_model, bis_rating_profiles)
    builder = new(issue, decision_review_model, bis_rating_profiles)
    builder.assign_attributes
    builder.request_issue
  end

  def initialize(issue, decision_review_model, bis_rating_profiles)
    @decision_review_model = decision_review_model
    @issue = issue
    @bis_rating_profiles = bis_rating_profiles
    @request_issue = DecisionReviewCreated::RequestIssue.new
    super()
  end

  def assign_attributes
    assign_methods
    calculate_methods
  end

  private

  def assign_methods
    assign_contested_rating_decision_reference_id
    assign_contested_rating_issue_reference_id
    assign_contested_decision_issue_id
    assign_untimely_exemption
    assign_untimely_exemption_notes
    assign_vacols_id
    assign_vacols_sequence_id
    assign_nonrating_issue_bgs_id
    assign_type
  end

  def calculate_methods
    calculate_contention_reference_id
    calculate_benefit_type
    calculate_contested_issue_description
    calculate_contested_rating_issue_profile_date
    calculate_decision_date
    calculate_ineligible_due_to_id
    calculate_ineligible_reason
    calculate_unidentified_issue_text
    calculate_nonrating_issue_category
    calculate_nonrating_issue_description
    calculate_closed_at
    calculate_closed_status
    calculate_contested_rating_issue_diagnostic_code
    calculate_rating_issue_associated_at
    calculate_ramp_claim_id
    calculate_is_unidentified
    calculate_nonrating_issue_bgs_source
  end

  ## THESE ONES DON'T PASS WHEN MIGRATED TO BASE
  ## ===========================================

  # used to determine if "TIME_RESTRICTION" eligibility_result maps to "untimely" or "before_ama" ineligible_reason
  def decision_date_before_ama?
    decision_date = prior_decision_date_converted_to_logical_type

    if decision_date
      ama_activation_date_logical_type = (AMA_ACTIVATION_DATE - EPOCH_DATE).to_i
      decision_date < ama_activation_date_logical_type
    end
  end

  def determine_benefit_type
    decision_review_model.ep_code.include?(PENSION_IDENTIFIER) ? PENSION_BENEFIT_TYPE : COMPENSATION_BENEFIT_TYPE
  end
end
