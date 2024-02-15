# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created do
    message_payload do
      {
        "claim_id" => 1_234_567,
        "decision_review_type" => "HIGHER_LEVEL_REVIEW",
        "veteran_first_name" => "John",
        "veteran_last_name" => "Smith",
        "veteran_participant_id" => "123456789",
        "file_number" => "123456789",
        "claimant_participant_id" => "5382910292",
        "ep_code" => "030HLRNR",
        "ep_code_category" => "Rating",
        "claim_received_date" => 1954,
        "claim_lifecycle_status" => "RFD",
        "payee_code" => "00",
        "modifier" => "01",
        "originated_from_vacols_issue" => false,
        "informal_conference_requested" => false,
        "informal_conference_tracked_item_id" => 1,
        "same_station_review_requested" => false,
        "intake_creation_time" => Time.now.utc.to_i,
        "claim_creation_time" => Time.now.utc.to_i,
        "created_by_username" => "BVADWISE101",
        "created_by_station" => "101",
        "created_by_application" => "PASYSACCTCREATE",
        "decision_review_issues" => decision_review_issues
      }
    end

    transient do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_789,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_text" => "service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 1954,
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
            "prior_decision_notification_date" => 1954,
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
      end
    end

    trait :invalid_attribute_name do
      message_payload { { "invalid_attribute" => "invalid" } }
    end

    trait :invalid_data_type do
      message_payload { { "claim_id" => "invalid" } }
    end

    trait :nil do
      message_payload { nil }
    end

    trait :empty do
      message_payload { {} }
    end

    trait :without_decision_review_issues do
      decision_review_issues { [] }
    end

    trait :with_nil_decision_review_issue do
      decision_review_issues { [nil, nil] }
    end

    trait :with_empty_decision_review_issue do
      decision_review_issues { [{}, {}] }
    end

    trait :with_invalid_decision_review_issue_attribute_name do
      decision_review_issues { [{ "invalid_attribute" => "is invalid" }] }
    end

    trait :with_invalid_decision_review_issue_data_type do
      decision_review_issues { [{ "contention_id" => "is supposed to be an integer" }] }
    end

    trait :pension do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => "123456789",
          "file_number" => "123456789",
          "claimant_participant_id" => "01010101",
          "ep_code" => "030HLRRPMC",
          "ep_code_category" => "Rating",
          "claim_received_date" => 18_475,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => 1,
          "same_station_review_requested" => false,
          "intake_creation_time" => 1_702_067_143_435,
          "claim_creation_time" => 1_702_067_145_000,
          "created_by_username" => "BVADWISE101",
          "created_by_station" => "101",
          "created_by_application" => "PASYSACCTCREATE",
          "decision_review_issues" => decision_review_issues
        }
      end
    end

    trait :soc_opt_in do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_789,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_text" => "service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => 987_654_321,
            "legacy_appeal_issue_id" => 9_876_543_212
          }
        ]
      end
    end

    trait :veteran_is_claimant do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => "123456789",
          "file_number" => "123456789",
          "claimant_participant_id" => "123456789",
          "ep_code" => "030HLRNR",
          "ep_code_category" => "Rating",
          "claim_received_date" => 18_475,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "same_station_review_requested" => false,
          "intake_creation_time" => 1_702_067_143_435,
          "claim_creation_time" => 1_702_067_145_000,
          "created_by_username" => "BVADWISE101",
          "created_by_station" => "101",
          "created_by_application" => "PASYSACCTCREATE",
          "decision_review_issues" => decision_review_issues
        }
      end
    end

    initialize_with { new(message_payload) }
  end
end
