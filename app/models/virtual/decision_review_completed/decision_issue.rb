# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCompleted::DecisionIssueBuilder
class DecisionReviewCreated::DecisionIssue
  attr_accessor :benefit_type, :decision_text, :description, :disposition, :end_product_last_action_date,
                :participant_id, :percent_number, :rating_issue_reference_id, :rating_profile_date,
                :rating_promulgation_date, :subject_text
end