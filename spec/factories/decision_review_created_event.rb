# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created_event,
          class: "Events::DecisionReviewCreatedEvent" do
    message_payload do
      {
        "claim_id" => 1_234_567,
        "decision_review_type" =>
        "HigherLevelReview",
        "veteran_first_name" => "John",
        "veteran_last_name" => "Smith",
        "veteran_participant_id" => "123456789",
        "file_number" => "123456789",
        "claimant_participant_id" => "01010101",
        "ep_code" => "030HLRNR",
        "ep_code_category" => "Rating",
        "claim_received_date" => Date.new(2022, 1, 1).to_time.to_s,
        "claim_lifecycle_status" => "RFD",
        "payee_code" => "00",
        "modifier" => "01",
        "originated_from_vacols_issue" => false,
        "informal_conference_requested" => false,
        "same_station_review_requested" => false,
        "intake_creation_time" => Time.now.utc.to_time.to_s,
        "claim_creation_time" => Time.now.utc.to_time.to_s,
        "actor_username" => "BVADWISE101",
        "actor_station" => "101",
        "actor_application" => "PASYSACCTCREATE",
        "decision_review_issues" => [
          {
            "contention_id" => 123_456_789,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_text" => "service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => Date.new(2022, 1, 1).to_time.to_s,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          },
          {
            "contention_id" => 987_654_321,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_text" => "service connection for ear infection denied",
            "prior_decision_type" => "Basic Eligibility",
            "prior_decision_notification_date" => Date.new(2022, 1, 1).to_time.to_s,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          }
        ]
      }.to_json
    end
    partition { 1 }
    sequence(:offset) { Event.any? ? (Event.last.offset + 1) : 1 }
  end
end
