# frozen_string_literal: true

FactoryBot.define do
  factory :claim_review do
    filed_by_va_gov { true }
    receipt_date { Time.now.utc }
    legacy_opt_in_approved { true }
    informal_conference { true }
    same_office { true }
  end
end
