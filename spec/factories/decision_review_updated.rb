# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated,
          class: "Transformers::DecisionReviewUpdated" do
    rating_hlr_pension

    decision_review_issues_created = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "ADD_CONTENTION",
        associated_caseflow_request_issue_id: nil,
        unidentified: true,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: nil,
        prior_caseflow_decision_issue_id: nil,
        prior_decision_text: "Service connection for tetnus denied",
        prior_decision_type: "Unknown",
        prior_decision_source: nil,
        prior_decision_notification_date: nil,
        prior_decision_date: nil,
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        prior_decision_rating_sn: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil,
        prior_decision_award_event_id: nil,
        prior_decision_rating_profile_date: nil,
        source_claim_id_for_remand: nil,
        source_contention_id_for_remand: nil,
        removed: false,
        withdrawn: false,
        decision: nil
      }
    ]

    decision_review_issues_updated = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "UPDATE_CONTENTION",
        associated_caseflow_request_issue_id: nil,
        unidentified: true,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: nil,
        prior_caseflow_decision_issue_id: nil,
        prior_decision_text: "Service connection for tetnus denied",
        prior_decision_type: "Unknown",
        prior_decision_source: nil,
        prior_decision_notification_date: nil,
        prior_decision_date: nil,
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        prior_decision_rating_sn: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil,
        prior_decision_award_event_id: nil,
        prior_decision_rating_profile_date: nil,
        source_claim_id_for_remand: nil,
        source_contention_id_for_remand: nil,
        removed: false,
        withdrawn: false,
        decision: nil
      }
    ]

    decision_review_issues_removed = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "DELETE_CONTENTION",
        associated_caseflow_request_issue_id: nil,
        unidentified: true,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: nil,
        prior_caseflow_decision_issue_id: nil,
        prior_decision_text: "Service connection for tetnus denied",
        prior_decision_type: "Unknown",
        prior_decision_source: nil,
        prior_decision_notification_date: nil,
        prior_decision_date: nil,
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        prior_decision_rating_sn: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil,
        prior_decision_award_event_id: nil,
        prior_decision_rating_profile_date: nil,
        source_claim_id_for_remand: nil,
        source_contention_id_for_remand: nil,
        removed: true,
        withdrawn: false,
        decision: nil
      }
    ]

    decision_review_issues_withdrawn = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "DELETE_CONTENTION",
        associated_caseflow_request_issue_id: nil,
        unidentified: true,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: nil,
        prior_caseflow_decision_issue_id: nil,
        prior_decision_text: "Service connection for tetnus denied",
        prior_decision_type: "Unknown",
        prior_decision_source: nil,
        prior_decision_notification_date: nil,
        prior_decision_date: nil,
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        prior_decision_rating_sn: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil,
        prior_decision_award_event_id: nil,
        prior_decision_rating_profile_date: nil,
        source_claim_id_for_remand: nil,
        source_contention_id_for_remand: nil,
        removed: false,
        withdrawn: true,
        decision: nil
      }
    ]

    decision_review_issues_not_changed = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "NONE",
        associated_caseflow_request_issue_id: nil,
        unidentified: true,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: nil,
        prior_caseflow_decision_issue_id: nil,
        prior_decision_text: "Service connection for tetnus denied",
        prior_decision_type: "Unknown",
        prior_decision_source: nil,
        prior_decision_notification_date: nil,
        prior_decision_date: nil,
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        prior_decision_rating_sn: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil,
        prior_decision_award_event_id: nil,
        prior_decision_rating_profile_date: nil,
        source_claim_id_for_remand: nil,
        source_contention_id_for_remand: nil,
        removed: false,
        withdrawn: false,
        decision: nil
      }
    ]

    trait :rating_hlr_pension do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "030HLRRPMC",
          ep_code_category: "rating",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :nonrating_hlr_pension do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "030HLRNRPMC",
          ep_code_category: "NON_RATING",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :rating_hlr_compensation do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "030HLRR",
          ep_code_category: "rating",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :nonrating_hlr_compensation do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "030HLRNR",
          ep_code_category: "NON_RATING",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :rating_sc_pension do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "040SCRPMC",
          ep_code_category: "rating",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :nonrating_sc_pension do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "040SCNRPMC",
          ep_code_category: "NON_RATING",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :rating_sc_compensation do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "040SCR",
          ep_code_category: "rating",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :nonrating_sc_compensation do
      message_payload do
        {
          claim_id: 710_002_659,
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: "210002659",
          file_number: "310002659",
          claimant_participant_id: "210002659",
          ep_code: "040SCNR",
          ep_code_category: "NON_RATING",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: nil,
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: "2024-07-12T21:51:22.000Z",
          actor_username: "BVADWISE101",
          actor_station: "101",
          actor_application: "PASYSACCTCREATE",
          auto_remand: false,
          decision_review_issues_created: decision_review_issues_created,
          decision_review_issues_updated: decision_review_issues_updated,
          decision_review_issues_removed: decision_review_issues_removed,
          decision_review_issues_withdrawn: decision_review_issues_withdrawn,
          decision_review_issues_not_changed: decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    # START: HLRs
    ## START: HLR Pension
    trait :rating_hlr_pension_issue_created do
      rating_hlr_pension
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_pension_issue_updated do
      rating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_pension_issue_removed do
      rating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_pension_issue_withdrawn do
      rating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_pension_issue_not_changed do
      rating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end

    trait :nonrating_hlr_pension_issue_created do
      nonrating_hlr_pension
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_pension_issue_updated do
      nonrating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_pension_issue_removed do
      nonrating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_pension_issue_withdrawn do
      nonrating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_pension_issue_not_changed do
      nonrating_hlr_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end
    ## END: HLR Pension

    ## START: HLR Compensation
    trait :rating_hlr_compensation_issue_created do
      rating_hlr_compensation
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_compensation_issue_updated do
      rating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_compensation_issue_removed do
      rating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_compensation_issue_withdrawn do
      rating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_hlr_compensation_issue_not_changed do
      rating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end

    trait :nonrating_hlr_compensation_issue_created do
      nonrating_hlr_compensation
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_compensation_issue_updated do
      nonrating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_compensation_issue_removed do
      nonrating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_compensation_issue_withdrawn do
      nonrating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_compensation_issue_not_changed do
      nonrating_hlr_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end
    ## END: HLR Compensation
    # END: HLRs

    # START: SCs
    ## START: SC Pension
    trait :rating_sc_pension_issue_created do
      rating_sc_pension
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_pension_issue_updated do
      rating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_pension_issue_removed do
      rating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_pension_issue_withdrawn do
      rating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_pension_issue_not_changed do
      rating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end

    trait :nonrating_sc_pension_issue_created do
      nonrating_sc_pension
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_pension_issue_updated do
      nonrating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_pension_issue_removed do
      nonrating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_pension_issue_withdrawn do
      nonrating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_pension_issue_not_changed do
      nonrating_sc_pension
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end
    ## END: SC Pension

    ## START: SC Compensation
    trait :rating_sc_compensation_issue_created do
      rating_sc_compensation
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_compensation_issue_updated do
      rating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_compensation_issue_removed do
      rating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_compensation_issue_withdrawn do
      rating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :rating_sc_compensation_issue_not_changed do
      rating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end

    trait :nonrating_sc_compensation_issue_created do
      nonrating_sc_compensation
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_compensation_issue_updated do
      nonrating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_compensation_issue_removed do
      nonrating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_compensation_issue_withdrawn do
      nonrating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_sc_compensation_issue_not_changed do
      nonrating_sc_compensation
      decision_review_issues_created { [] }
      decision_review_issues_updated { [] }
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
    end
    ## END: SC Compensation
    # END: SCs

    initialize_with { new(event_id, message_payload) }
  end
end
