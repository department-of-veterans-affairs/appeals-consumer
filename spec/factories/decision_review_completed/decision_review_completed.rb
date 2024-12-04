# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_completed, class: "Transformers::DecisionReviewCompleted" do
  end
end

def base_message_payload(**args)
  {
    "claim_id" => Faker::Number.number(digits: 7),
    "original_source" => args[:original_source] || "CP",
    "decision_review_type" => "HIGHER_LEVEL_REVIEW",
    "veteran_last_name" => "Smith",
    "veteran_first_name" => "John",
    "veteran_participant_id" => args[:participant_id] || Faker::Number.number(digits: 9).to_s,
    "file_number" => Faker::Number.number(digits: 9).to_s,
    "claimant_participant_id" => args[:participant_id] || Faker::Number.number(digits: 9).to_s,
    "ep_code" => "030HLRR",
    "ep_code_category" => args[:ep_code_category] || "rating",
    "claim_received_date" => "2023-08-25",
    "claim_lifecycle_status" => "Closed",
    "payee_code" => "00",
    "modifier" => "030",
    "originated_from_vacols_issue" => nil,
    "limited_poa_code" => nil,
    "informal_conference_tracked_item_id" => nil,
    "informal_conference_requested" => args[:informal_conference_requested] || false,
    "same_station_review_requested" => args[:same_station_review_requested] || false,
    "completion_time" => Time.zone.now.to_s,
    "claim_creation_time" => Time.zone.now.to_s,
    "actor_username" => "BVADWISE101",
    "actor_station" => "101",
    "actor_application" => "PASYSACCTCREATE",

    "auto_remand" => false,
    "decision_review_issues_completed" => args[:decision_review_issues_completed] ||
      [review_issues_created_attributes]
  }
end
