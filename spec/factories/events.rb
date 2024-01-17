# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    type { "Topics::DecisionReviewCreatedTopic::Events::DecisionReviewCreatedEvent" }
    message_payload { "{\"something\": 1}" }
  end
end
