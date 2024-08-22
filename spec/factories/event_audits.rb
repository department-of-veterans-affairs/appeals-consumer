# frozen_string_literal: true

FactoryBot.define do
  factory :event_audit do
    event

    trait :stuck do
      status { "in_progress" }
      started_at { 30.minutes.ago }
      ended_at { nil }
    end
  end
end
