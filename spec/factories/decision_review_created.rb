# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created do
    nonrating_message_payload

    transient do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_789,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 1954,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
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
            "contention_id" => 123_456_790,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Basic Eligibility: Service connection for ear infection denied",
            "prior_decision_type" => "Basic Eligibility",
            "prior_decision_notification_date" => 1954,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
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

    trait :rating_message_payload do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => "123456789",
          "file_number" => "123456789",
          "claimant_participant_id" => "123456789",
          "ep_code" => "030HLRR",
          "ep_code_category" => "rating",
          "claim_received_date" => 18_475,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
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

    trait :nonrating_message_payload do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => "123456789",
          "file_number" => "123456789",
          "claimant_participant_id" => "01010101",
          "ep_code" => "030HLRNR",
          "ep_code_category" => "non-rating",
          "claim_received_date" => 1954,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => 1,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.now.utc.to_i * 1000,
          "claim_creation_time" => Time.now.utc.to_i * 1000,
          "created_by_username" => "BVADWISE101",
          "created_by_station" => "101",
          "created_by_application" => "PASYSACCTCREATE",
          "decision_review_issues" => decision_review_issues
        }
      end
    end

    trait :supplemental_message_payload do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "SUPPLEMENTAL_CLAIM",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => "123456789",
          "file_number" => "123456789",
          "claimant_participant_id" => "01010101",
          "ep_code" => "040SCNR",
          "ep_code_category" => "non-rating",
          "claim_received_date" => 18_475,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
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

    trait :unidentified_supplemental do
      supplemental_message_payload
      unidentified
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
          "ep_code" => "030HLRNRPMC",
          "ep_code_category" => "non-rating",
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
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => false,
            "soc_opt_in" => true,
            "legacy_appeal_id" => 987_654_321,
            "legacy_appeal_issue_id" => 1
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
          "ep_code_category" => "non-rating",
          "claim_received_date" => 18_475,
          "claim_lifecycle_status" => "RW",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
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

    trait :ineligible_contested do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => true,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          }
        ]
      end
    end

    trait :ineligible_contested_with_additional_issue do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => true,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          },
          {
            "contention_id" => 123_456_764,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Basic Eligibility: Service connection for ear infection denied",
            "prior_decision_type" => "Basic Eligibility",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
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

    trait :rating_issue do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
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

    trait :rating_decision do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Tetnus is denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => "1623547",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
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

    trait :decision_issue_prior_rating_issue do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "associated_caseflow_decision_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
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

    trait :decision_issue_prior_non_rating_issue do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "associated_caseflow_decision_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
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

    trait :ineligible_time_restriction_before_ama do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_945,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_945,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "TIME_RESTRICTION",
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

    trait :ineligible_time_restriction_untimely do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => false,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_pending_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_HLR",
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

    trait :ineligible_rating_pending_hlr do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => 12,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
            "eligible" => false,
            "eligibility_result" => "PENDING_HLR",
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

    trait :ineligible_nonrating_pending_board do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_BOARD",
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

    trait :ineligible_rating_pending_board do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => 12,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
            "eligible" => false,
            "eligibility_result" => "PENDING_BOARD",
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

    trait :ineligible_nonrating_pending_supplemental do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
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

    trait :ineligible_rating_pending_supplemental do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => 12,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
            "eligible" => false,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
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

    trait :ineligible_completed_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "COMPLETED_HLR",
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

    trait :ineligible_completed_board do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "COMPLETED_BOARD",
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

    trait :ineligible_pending_legacy_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => 123_456,
            "legacy_appeal_issue_id" => 1
          }
        ]
      end
    end

    trait :ineligible_legacy_time_restriction do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_940,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_940,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => 123_456,
            "legacy_appeal_issue_id" => 1
          }
        ]
      end
    end

    trait :ineligible_no_soc_ssoc do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => 123_456,
            "legacy_appeal_issue_id" => 1
          }
        ]
      end
    end

    trait :unidentified do
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
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

    trait :eligible_time_override do
      decision_review_issues do
        [
          {
            "contention_id" => 12_369_792,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "form was not sent on time",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil
          }
        ]
      end
    end

    trait :legacy_issue do
      decision_review_issues do
        [
          {
            "contention_id" => 12_369_792,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 10,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_ramp_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => 17_946,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => 12_345,
            "legacy_appeal_issue_id" => 1
          }
        ]
      end
    end

    trait :rating_with_ramp_id do
      rating_message_payload
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "associated_caseflow_decision_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_ramp_id" => 123_567,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => 18_475,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_disability_sequence_number" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "12/20/2021",
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

    initialize_with { new(message_payload) }
  end
end
