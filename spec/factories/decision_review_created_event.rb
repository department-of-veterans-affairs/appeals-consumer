# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created_event, class: "Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent" do
    message_payload { { "something": 1, "claim_id": 1 }.to_json }
    partition { 1 }
    offset { 1 }
  end
end