# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    type { "Events::DecisionReviewCreatedEvent" }
    message_payload { { "something": 1, "claim_id": 1 }.to_json }
    partition { 1 }
    sequence(:offset) { Event.any? ? (Event.last.offset + 1) : 1 }
  end
end
