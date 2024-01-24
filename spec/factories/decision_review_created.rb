# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created do
    transient do
      decision_review_issues do
        [
          {
            contention_id: 123_456_789,
            associated_caseflow_request_issue_id: nil,
            unidentified: false,
            prior_rating_decision_id: nil,
            prior_non_rating_decision_id: 12,
            prior_decision_text: "service connection for tetnus denied",
            prior_decision_type: "DIC",
            prior_decision_notification_date: Date.new(2022, 1, 1),
            prior_decision_diagnostic_code: nil,
            prior_decision_rating_percentage: nil,
            eligible: true,
            eligibility_result: "ELIGIBLE",
            time_override: nil,
            time_override_reason: nil,
            contested: nil,
            soc_opt_in: nil,
            legacy_appeal_id: nil,
            legacy_appeal_issue_id: nil
          },
          {
            contention_id: 987_654_321,
            associated_caseflow_request_issue_id: nil,
            unidentified: false,
            prior_rating_decision_id: nil,
            prior_non_rating_decision_id: 13,
            prior_decision_text: "service connection for ear infection denied",
            prior_decision_type: "Basic Eligibility",
            prior_decision_notification_date: Date.new(2022, 1, 1),
            prior_decision_diagnostic_code: nil,
            prior_decision_rating_percentage: nil,
            eligible: true,
            eligibility_result: "ELIGIBLE",
            time_override: nil,
            time_override_reason: nil,
            contested: nil,
            soc_opt_in: nil,
            legacy_appeal_id: nil,
            legacy_appeal_issue_id: nil
          }
        ]
      end

      message_payload do
        {
          claim_id: 1_234_567,
          decision_review_type: "HigherLevelReview",
          veteran_first_name: "John",
          veteran_last_name: "Smith",
          veteran_participant_id: "123456789",
          veteran_file_number: "123456789",
          claimant_participant_id: "01010101",
          ep_code: "030HLRNR",
          ep_code_category: "Rating",
          claim_received_date: Date.new(2022, 1, 1),
          claim_lifecycle_status: "RFD",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          informal_conference_requested: false,
          same_station_requested: false,
          intake_creation_time: Time.now.utc,
          claim_creation_time: Time.now.utc,
          created_by_username: "BVADWISE101",
          created_by_station: "101",
          created_by_application: "PASYSACCTCREATE",
          decision_review_issues: decision_review_issues
        }
      end
    end

    trait :invalid_attribute_name do
      message_payload { { invalid_attribute: "invalid" } }
    end

    trait :invalid_data_type do
      message_payload { { claim_id: "invalid" } }
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
      decision_review_issues { [{ invalid_attribute: "is invalid" }] }
    end

    trait :with_invalid_decision_review_issue_data_type do
      decision_review_issues { [{ contention_id: "is supposed to be an integer" }] }
    end

    initialize_with { new(message_payload) }
  end
end