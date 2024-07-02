# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_created,
          class: "Transformers::DecisionReviewCreated" do
    nonrating_hlr_veteran_claimant

    transient do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_789,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil,
            "prior_decision_source" => nil
          },
          {
            "contention_id" => 123_456_790,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => 17_946,
            "prior_decision_text" => "Basic Eligibility: Service connection for ear infection denied",
            "prior_decision_type" => "Basic Eligibility",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil,
            "prior_decision_source" => nil
          }
        ]
      end
    end

    # START: Payloads that raise error upon DecisionReviewCreated initialization
    trait :invalid_attribute_name do
      message_payload { { "invalid_attribute" => "invalid" } }
      event_id { nil }
    end

    trait :invalid_data_type do
      message_payload { { "claim_id" => "invalid" } }
      event_id { nil }
    end

    trait :nil do
      message_payload { nil }
      event_id { nil }
    end

    trait :empty do
      message_payload { {} }
      event_id { nil }
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
    # END: Payloads that raise error upon DecisionReviewCreated initialization

    # START: Valid DecisionReviewCreated Scenarios
    trait :nonrating_hlr_veteran_claimant do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRNR",
          "ep_code_category" => "NON_RATING",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => "1",
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :nonrating_hlr_non_veteran_claimant do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRNR",
          "ep_code_category" => "NON_RATING",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :nonrating_sc_compensation do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "SUPPLEMENTAL_CLAIM",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "040SCNR",
          "ep_code_category" => "NON_RATING",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :rating_sc_compensation do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "SUPPLEMENTAL_CLAIM",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "040SCR",
          "ep_code_category" => "rating",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :nonrating_hlr_pension do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRNRPMC",
          "ep_code_category" => "NON_RATING",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => "1",
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :rating_hlr_veteran_claimant do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRR",
          "ep_code_category" => "rating",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end

    trait :rating_hlr_non_veteran_claimant do
      message_payload do
        {
          "claim_id" => 1_234_567,
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_first_name" => "John",
          "veteran_last_name" => "Smith",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRR",
          "ep_code_category" => "rating",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "limited_poa_code" => nil,
          "originated_from_vacols_issue" => false,
          "informal_conference_requested" => false,
          "informal_conference_tracked_item_id" => nil,
          "same_station_review_requested" => false,
          "intake_creation_time" => Time.zone.now.to_s,
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues" => decision_review_issues
        }
      end
      event_id { nil }
    end
    # END: DecisionReviewCreated Scenarios

    # START: DecisionReviewIssue Scenarios
    ## Nonating HLR
    ### START: Valid Eligible Nonrating HLR
    trait :eligible_nonrating_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_veteran_claimant do
      nonrating_hlr_veteran_claimant
      eligible_nonrating_hlr
    end

    trait :eligible_nonrating_hlr_non_veteran_claimant do
      nonrating_hlr_non_veteran_claimant
      eligible_nonrating_hlr
    end

    trait :eligible_nonrating_hlr_with_two_issues do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          },
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 14,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_contested_with_additional_issue do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          },
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 14,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_time_override do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_with_decision_source do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC:",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil,
            "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE"
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_legacy do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_date" => "2023-08-01",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Eligible Nonrating HLR

    ### START: Valid Ineligible Nonrating HLR
    trait :ineligible_nonrating_hlr_pending_board_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_pending_supplemental do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => false,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_time_restriction_untimely do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_time_restriction_before_ama do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2018-08-01",
            "prior_decision_date" => "2018-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_no_soc_ssoc do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_pending_legacy_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_legacy_time_restriction do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_pending_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_completed_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "COMPLETED_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_completed_board_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "COMPLETED_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Ineligible Nonrating HLR

    ### START: Invalid Nonrating HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_nonrating_hlr_without_prior_decision_date do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_pending_hlr_without_ri_id do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_with_contention_id do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_without_contention_id do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_nonrating_hlr_contested do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Nonrating HLR
    ## END: Nonrating HLR

    ## START: Nonrating Unidentified HLR
    ### START: Valid Eligible Nonrating Unidentfiied HLR
    # unidentified issues will never be ineligible upon being intaken,
    # eligibility is determined once the issue is identified
    trait :eligible_nonrating_hlr_unidentified do
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_unidentified_with_decision_source do
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil,
            "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE"
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_unidentified_veteran_claimant do
      eligible_nonrating_hlr_unidentified
    end

    trait :eligible_nonrating_hlr_unidentified_non_veteran_claimant do
      nonrating_hlr_non_veteran_claimant
      eligible_nonrating_hlr_unidentified
    end
    ### END: Valid Eligible Nonrating Unidentified HLR

    ### START: Invalid Nonrating Unidentified HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_nonrating_hlr_unidentified_without_prior_decision_date do
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_nonrating_hlr_unidentified_without_contention_id do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Nonrating Unidentified HLR
    ## END: Nonrating Unidentified HLR

    ## START: Nonrating Prior Caseflow Decision Issue HLR
    ### START: Valid Eligible Nonrating Prior Caseflow Decision Issue HLR
    trait :eligible_decision_issue_prior_nonrating_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "prior_caseflow_decision_issue_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_non_veteran_claimant do
      nonrating_hlr_non_veteran_claimant
      eligible_decision_issue_prior_nonrating_hlr
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_veteran_claimant do
      eligible_decision_issue_prior_nonrating_hlr
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_time_override do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 20,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_with_decision_source do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 20,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil,
            "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE"
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_legacy do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Eligible Nonrating Prior Caseflow Decision Issue HLR

    ### START: Invalid Nonrating Prior Caseflow Decision Issue HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_decision_issue_prior_nonrating_hlr_without_prior_decision_date do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "prior_caseflow_decision_issue_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_hlr_without_ri_id do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 12,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_with_contention_id do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_without_contention_id do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Nonrating Prior Caseflow Decision Issue HLR

    ### START: Valid Ineligible Nonrating Prior Caseflow Decision Issue HLR
    trait :ineligible_decision_issue_prior_nonrating_hlr_time_restriction_untimely do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_time_restriction_before_ama do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 20,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2018-08-01",
            "prior_decision_date" => "2018-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_no_soc_ssoc do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_legacy_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_legacy_time_restriction do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 14,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_board_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 14,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_supplemental do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 14,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_completed_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "COMPLETED_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_completed_board_appeal do
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => 13,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "DIC: Service connection for tetnus denied",
            "prior_decision_type" => "DIC",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "COMPLETED_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Ineligible Nonrating Prior Caseflow Decision Issue HLR
    ## END: Nonrating Prior Caseflow Decision Issue HLR

    ## Rating HLR
    ### START: Valid Eligible Rating HLR
    trait :eligible_rating_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_non_veteran_claimant do
      rating_hlr_non_veteran_claimant
      eligible_rating_hlr
    end

    trait :eligible_rating_hlr_veteran_claimant do
      rating_hlr_veteran_claimant
      eligible_rating_hlr
    end

    trait :eligible_rating_hlr_time_override do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_with_two_issues do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-25",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          },
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 14,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-25",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-10T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_contested_with_additional_issue do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-25",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          },
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 14,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-25",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_legacy do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Eligible Rating HLR

    ### START: Valid Ineligible Rating HLR
    trait :ineligible_rating_hlr_pending_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => 12,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => false,
            "eligibility_result" => "PENDING_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_pending_supplemental do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 13,
            "unidentified" => false,
            "prior_rating_decision_id" => 12,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => false,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_time_restriction_untimely do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_time_restriction_before_ama do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2018-08-01",
            "prior_decision_date" => "2018-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_no_soc_ssoc do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_pending_legacy_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_legacy_time_restriction do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_pending_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_completed_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_completed_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Ineligible Rating HLR

    ### START: Invalid Rating HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_rating_hlr_without_prior_decision_date do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_pending_hlr_without_ri_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_contested do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "CONTESTED",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_hlr_with_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_without_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Rating HLR
    ## END: Rating HLR

    ## START: Rating Unidentified HLR
    ### START: Valid Eligible Rating Unidentfiied HLR
    # unidentified issues will never be ineligible upon being intaken,
    # eligibility is determined once the issue is identified
    trait :eligible_rating_hlr_unidentified do
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_unidentified_veteran_claimant do
      rating_hlr_veteran_claimant
      eligible_rating_hlr_unidentified
    end

    trait :eligible_rating_hlr_unidentified_non_veteran_claimant do
      rating_hlr_non_veteran_claimant
      eligible_rating_hlr_unidentified
    end
    ### END: Valid Eligible Rating Unidentified HLR

    ### START: Invalid Rating Unidentified HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_rating_hlr_unidentified_without_prior_decision_date do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 12_345_980,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_hlr_unidentified_without_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => true,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Rating Unidentified HLR
    ## END: Rating Unidentified HLR

    ## START: Rating Prior Caseflow Decision Issue HLR
    ### START: Valid Eligible Rating Prior Caseflow Decision Issue HLR
    trait :eligible_decision_issue_prior_rating_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "prior_caseflow_decision_issue_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_non_veteran_claimant do
      rating_hlr_non_veteran_claimant
      eligible_decision_issue_prior_rating_hlr
    end

    trait :eligible_decision_issue_prior_rating_hlr_veteran_claimant do
      rating_hlr_veteran_claimant
      eligible_decision_issue_prior_rating_hlr
    end

    trait :eligible_decision_issue_prior_rating_hlr_time_override do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 20,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2023-08-25",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_legacy do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Eligible Rating Prior Caseflow Decision Issue HLR

    ### START: Invalid Rating Prior Caseflow Decision Issue HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_decision_issue_prior_rating_hlr_without_prior_decision_date do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_792,
            "prior_caseflow_decision_issue_id" => 11,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_hlr_without_ri_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_with_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_without_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    ### END: Invalid Rating Prior Caseflow Decision Issue HLR

    ### START: Valid Ineligible Rating Prior Caseflow Decision Issue HLR
    trait :ineligible_decision_issue_prior_rating_hlr_time_restriction_untimely do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_time_restriction_before_ama do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 20,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 13,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2018-08-01",
            "prior_decision_date" => "2018-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_no_soc_ssoc do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_legacy_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_legacy_time_restriction do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_supplemental do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_completed_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_completed_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => 13,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => 20,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Ineligible Rating Prior Caseflow Decision Issue HLR
    ## END: Rating Prior Caseflow Decision Issue HLR

    ## START: Rating Decision HLR
    ### START: Valid Eligible Rating Decision HLR
    trait :eligible_rating_decision_hlr do
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Tetnus is denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "1_623_547",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_decision_hlr_non_veteran_claimant do
      rating_hlr_non_veteran_claimant
      eligible_rating_decision_hlr
    end

    trait :eligible_rating_decision_hlr_veteran_claimant do
      rating_hlr_veteran_claimant
      eligible_rating_decision_hlr
    end

    trait :eligible_rating_decision_hlr_time_override do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2020-08-25",
            "prior_decision_date" => "2020-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => true,
            "time_override_reason" => "good cause exemption",
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_decision_hlr_legacy do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE_LEGACY",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Eligible Rating Decision HLR

    ### START: Invalid Rating Decision HLR
    # these records will fail to process within DecisionReviewCreatedEvenprocessingJob
    trait :eligible_rating_decision_hlr_without_prior_decision_date do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_pending_hlr_without_ri_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_with_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => 123_456_791,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :eligible_rating_decision_hlr_without_contention_id do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Invalid Rating Decision HLR

    ### START: Valid Ineligible Rating Decision HLR
    trait :ineligible_rating_decision_hlr_time_restriction_untimely do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_time_restriction_before_ama do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2018-08-01",
            "prior_decision_date" => "2018-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_no_soc_ssoc do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "NO_SOC_SSOC",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_pending_legacy_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_LEGACY_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_legacy_time_restriction do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2022-08-01",
            "prior_decision_date" => "2022-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "LEGACY_TIME_RESTRICTION",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => "LEGACYID",
            "legacy_appeal_issue_id" => 1,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_pending_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_pending_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_pending_supplemental do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => 12,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "PENDING_SUPPLEMENTAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_completed_hlr do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_HLR",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end

    trait :ineligible_rating_decision_hlr_completed_board_appeal do
      rating_hlr_veteran_claimant
      decision_review_issues do
        [
          {
            "contention_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Disability Evaluation",
            "prior_decision_notification_date" => "2023-08-01",
            "prior_decision_date" => "2023-08-01",
            "prior_decision_diagnostic_code" => "5008",
            "prior_decision_rating_sn" => "20",
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
            "eligible" => true,
            "eligibility_result" => "COMPLETED_BOARD_APPEAL",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => nil,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "source_contention_id_for_remand" => nil,
            "source_claim_id_for_remand" => nil
          }
        ]
      end
    end
    ### END: Valid Ineligible Rating Decision HLR
    ## END: Rating Decision HLR
    # END: DecisionReviewIssue Scenarios

    initialize_with { new(event_id, message_payload) }
  end
end
