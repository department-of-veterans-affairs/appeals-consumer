# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCreated::RequestIssueBuilder
class DecisionReviewCreated::RequestIssue
  attr_accessor :contested_issue_description, :contention_reference_id, :contested_rating_decision_reference_id,
                :contested_rating_issue_profile_date, :contested_rating_issue_reference_id,
                :contested_decision_issue_id, :decision_date, :ineligible_due_to_id, :ineligible_reason,
                :is_unidentified, :unidentified_issue_text, :nonrating_issue_category, :nonrating_issue_description,
                :untimely_exemption, :untimely_exemption_notes, :vacols_id, :vacols_sequence_id, :benefit_type,
                :closed_at, :closed_status, :contested_rating_issue_diagnostic_code, :ramp_claim_id,
                :rating_issue_associated_at, :type, :nonrating_issue_bgs_id, :nonrating_issue_bgs_source
end
