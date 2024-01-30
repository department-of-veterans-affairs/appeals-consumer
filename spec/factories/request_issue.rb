# frozen_string_literal: true

FactoryBot.define do
  factory :request_issue do
    contested_issue_description { "service connection for migraine is denied" }
    contention_reference_id { "123456789" }
    contested_rating_decision_reference_id { nil }
    contested_rating_issue_profile_date { Date.new(2022, 1, 1) }
    contested_rating_issue_reference_id { "963852741" }
    contested_decision_issue_id { nil }
    decision_date { Date.new(2022, 2, 1) }
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
  end
end
