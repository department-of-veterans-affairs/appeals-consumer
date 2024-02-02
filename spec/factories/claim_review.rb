# frozen_string_literal: true

FactoryBot.define do
  factory :claim_review do
    benefit_type { "compensation" }
    filed_by_va_gov { true }
    receipt_date { Time.now.utc }
    legacy_opt_in_approved { true }
    establishment_attempted_at { Time.now.utc }
    establishment_last_submitted_at { Time.now.utc }
    establishment_processed_at { Time.now.utc }
    establishment_submitted_at { Time.now.utc }
    informal_conference { true }
    same_office { true }
  end
end
