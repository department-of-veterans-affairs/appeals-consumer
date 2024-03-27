# frozen_string_literal: true

FactoryBot.define do
  factory :intake,
          class: "DecisionReviewCreated::Intake" do
    started_at { Time.now.utc - 1.minute }
    completion_started_at { Time.now.utc }
    completed_at { Time.now.utc }
    completion_status { "success" }
    type { "HigherLevelReviewIntake" }
  end
end
