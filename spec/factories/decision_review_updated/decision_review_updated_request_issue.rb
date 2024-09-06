# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated_request_issue, class: "DecisionReviewUpdated::RequestIssue" do
    benefit_type { "compensation" }
    contested_issue_description { nil }
    contention_reference_id { "123456789" }
    contested_rating_decision_reference_id { nil }
    contested_rating_issue_profile_date { Date.new(2022, 1, 1) }
    contested_rating_issue_reference_id { "963852741" }
    contested_decision_issue_id { nil }
    decision_date { Date.new(2022, 2, 1) }
    decision_review_issue_id { "123456789" }
    ineligible_due_to_id { nil }
    ineligible_reason { nil }
    is_unidentified { false }
    unidentified_issue_text { nil }
    nonrating_issue_category { nil }
    nonrating_issue_description { nil }
    untimely_exemption { nil }
    untimely_exemption_notes { nil }
    vacols_id { nil }
    vacols_sequence_id { nil }
    closed_at { nil }
    closed_status { nil }
    contested_rating_issue_diagnostic_code { nil }
    ramp_claim_id { "123456789" }
    rating_issue_associated_at { Time.now.utc }
    type { "RequestIssue" }
    nonrating_issue_bgs_id { nil }
    nonrating_issue_bgs_source { nil }

    trait :removed_request_issue do
      closed_at { DateTime.new(2022, 2, 1) }
      closed_status { "removed" }
    end

    trait :ineligible_to_ineligible_request_issue do
      closed_at { DateTime.new(2022, 2, 1) }
      closed_status { "ineligible" }
      ineligible_reason { "untimely" }
    end

    trait :updated_request_issue do
      contested_issue_description { "UPDATED" }
      contested_rating_issue_diagnostic_code { 5008 }
    end
  end
end
