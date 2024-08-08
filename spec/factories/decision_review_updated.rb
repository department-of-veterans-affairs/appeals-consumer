# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated,
          class: "Transformers::DecisionReviewUpdated" do
    nonrating_hlr_veteran_claimant

    decision_review_issues_created = [
      {
        decision_review_issue_id: 22,
        contention_id: 710_002_659,
        contention_action: "ADD_CONTENTION",
        associated_caseflow_request_issue_id: nil,
        unidentified: false,
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
        unidentified: false,
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
        unidentified: false,
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
        unidentified: false,
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
        unidentified: false,
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

    trait :eligible_rating_hlr_veteran_claimant do
      rating_hlr_pension
    end

    trait :eligible_nonrating_hlr_veteran_claimant do
      nonrating_hlr_pension
    end

    trait :eligible_rating_decision_hlr_veteran_claimant do
    end

    trait :eligible_decision_issue_prior_rating_hlr_veteran_claimant do
    end

    trait :eligible_rating_hlr_unidentified_veteran_claimant do
      decision_review_issues_created.first[:unidentified] = true
      decision_review_issues_updated.first[:unidentified] = true
      decision_review_issues_removed.first[:unidentified] = true
      decision_review_issues_withdrawn.first[:unidentified] = true
      decision_review_issues_not_changed.first[:unidentified] = true
    end

    trait :eligible_rating_hlr_unidentified_without_contention_id do
      decision_review_issues_created.first[:unidentified] = true
      decision_review_issues_created.first[:contention_id] = nil

      decision_review_issues_updated.first[:unidentified] = true
      decision_review_issues_updated.first[:contention_id] = nil

      decision_review_issues_removed.first[:unidentified] = true
      decision_review_issues_removed.first[:contention_id] = nil

      decision_review_issues_withdrawn.first[:unidentified] = true
      decision_review_issues_withdrawn.first[:contention_id] = nil

      decision_review_issues_not_changed.first[:unidentified] = true
      decision_review_issues_not_changed.first[:contention_id] = nil
    end

    trait :eligible_rating_hlr_without_contention_id do
      decision_review_issues_created.first[:contention_id] = nil
      decision_review_issues_updated.first[:contention_id] = nil
      decision_review_issues_removed.first[:contention_id] = nil
      decision_review_issues_withdrawn.first[:contention_id] = nil
      decision_review_issues_not_changed.first[:contention_id] = nil
    end

    trait :eligible_rating_decision_hlr_without_contention_id do
      decision_review_issues_created.first[:contention_id] = nil
      decision_review_issues_updated.first[:contention_id] = nil
      decision_review_issues_removed.first[:contention_id] = nil
      decision_review_issues_withdrawn.first[:contention_id] = nil
      decision_review_issues_not_changed.first[:contention_id] = nil
    end

    trait :eligible_decision_issue_prior_rating_hlr_without_contention_id do
      decision_review_issues_created.first[:contention_id] = nil
      decision_review_issues_updated.first[:contention_id] = nil
      decision_review_issues_removed.first[:contention_id] = nil
      decision_review_issues_withdrawn.first[:contention_id] = nil
      decision_review_issues_not_changed.first[:contention_id] = nil
    end

    trait :eligible_rating_hlr do
      rating_hlr_pension
    end

    trait :eligible_rating_hlr_legacy do
      rating_hlr_pension
      decision_review_issues_created.first[:eligibility_result] = "ELIGIBLE_LEGACY"
      decision_review_issues_created.first[:legacy_appeal_id] = 10
      decision_review_issues_created.first[:legacy_appeal_issue_id] = 1

      decision_review_issues_updated.first[:eligibility_result] = "ELIGIBLE_LEGACY"
      decision_review_issues_updated.first[:legacy_appeal_id] = 11
      decision_review_issues_updated.first[:legacy_appeal_issue_id] = 2

      decision_review_issues_removed.first[:eligibility_result] = "ELIGIBLE_LEGACY"
      decision_review_issues_removed.first[:legacy_appeal_id] = 12
      decision_review_issues_removed.first[:legacy_appeal_issue_id] = 3

      decision_review_issues_withdrawn.first[:eligibility_result] = "ELIGIBLE_LEGACY"
      decision_review_issues_withdrawn.first[:legacy_appeal_id] = 13
      decision_review_issues_withdrawn.first[:legacy_appeal_issue_id] = 4

      decision_review_issues_not_changed.first[:eligibility_result] = "ELIGIBLE_LEGACY"
      decision_review_issues_not_changed.first[:legacy_appeal_id] = 14
      decision_review_issues_not_changed.first[:legacy_appeal_issue_id] = 5
    end

    trait :ineligible_rating_hlr_contested do
      decision_review_issues_created.first[:eligible] = false
      decision_review_issues_created.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_updated.first[:eligible] = false
      decision_review_issues_updated.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_removed.first[:eligible] = false
      decision_review_issues_removed.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_withdrawn.first[:eligible] = false
      decision_review_issues_withdrawn.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_not_changed.first[:eligible] = false
      decision_review_issues_not_changed.first[:eligibility_result] = "INELIGIBLE"
    end

    trait :ineligible_rating_hlr_pending_hlr_without_ri_id do
      decision_review_issues_created.first[:eligible] = false
      decision_review_issues_created.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_updated.first[:eligible] = false
      decision_review_issues_updated.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_removed.first[:eligible] = false
      decision_review_issues_removed.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_withdrawn.first[:eligible] = false
      decision_review_issues_withdrawn.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_not_changed.first[:eligible] = false
      decision_review_issues_not_changed.first[:eligibility_result] = "INELIGIBLE"
    end

    trait :ineligible_rating_hlr_time_restriction_untimely do
      decision_review_issues_created.first[:eligible] = false
      decision_review_issues_created.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_updated.first[:eligible] = false
      decision_review_issues_updated.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_removed.first[:eligible] = false
      decision_review_issues_removed.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_withdrawn.first[:eligible] = false
      decision_review_issues_withdrawn.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_not_changed.first[:eligible] = false
      decision_review_issues_not_changed.first[:eligibility_result] = "INELIGIBLE"
    end

    trait :ineligible_rating_hlr_completed_hlr do
      decision_review_issues_created.first[:eligible] = false
      decision_review_issues_created.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_updated.first[:eligible] = false
      decision_review_issues_updated.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_removed.first[:eligible] = false
      decision_review_issues_removed.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_withdrawn.first[:eligible] = false
      decision_review_issues_withdrawn.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_not_changed.first[:eligible] = false
      decision_review_issues_not_changed.first[:eligibility_result] = "INELIGIBLE"
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_veteran_claimant do
    end

    trait :eligible_nonrating_hlr_unidentified_veteran_claimant do
    end

    trait :eligible_nonrating_hlr_unidentified_without_contention_id do
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_without_contention_id do
    end

    trait :eligible_nonrating_hlr_without_contention_id do
    end

    trait :eligible_rating_hlr_with_two_issues do
    end

    trait :ineligible_rating_hlr_contested_with_additional_issue do
      decision_review_issues_created.first[:eligible] = false
      decision_review_issues_created.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_updated.first[:eligible] = false
      decision_review_issues_updated.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_removed.first[:eligible] = false
      decision_review_issues_removed.first[:eligibility_result] = "INELIGIBLE"

      decision_review_issues_withdrawn.first[:eligible] = false
      decision_review_issues_withdrawn.first[:eligibility_result] = "INELIGIBLE"

      #   decision_review_issues_not_changed.first[:eligible] = false
      #   decision_review_issues_not_changed.first[:eligibility_result] = "INELIGIBLE"
      decision_review_issues_not_changed do
        [
          decision_review_issues_not_changed[0],
          decision_review_issues_not_changed[0]
        ]
      end
    end

    trait :nonrating_hlr_veteran_claimant do
      message_payload do
        {
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
          ep_code: "030HLRNR",
          ep_code_category: "NON_RATING",
          claim_received_date: "2023-08-25",
          claim_lifecycle_status: "Ready to Work",
          payee_code: "00",
          modifier: "01",
          originated_from_vacols_issue: false,
          limited_poa_code: nil,
          tracked_item_action: "ADD_TRACKED_ITEM",
          informal_conference_tracked_item_id: "1",
          informal_conference_requested: false,
          same_station_review_requested: false,
          update_time: "1_722_435_298_953",
          claim_creation_time: Time.zone.now.to_s,
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

    trait :nonrating_hlr_non_veteran_claimant do
      message_payload do
        {
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
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
          claim_creation_time: Time.zone.now.to_s,
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
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
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
          claim_creation_time: Time.zone.now.to_s,
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
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "SUPPLEMENTAL_CLAIM",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
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
          claim_creation_time: Time.zone.now.to_s,
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
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
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
          claim_creation_time: Time.zone.now.to_s,
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

    trait :rating_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s

      message_payload do
        {
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: participant_id,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: participant_id,
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
          claim_creation_time: Time.zone.now.to_s,
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

    trait :rating_hlr_non_veteran_claimant do
      message_payload do
        {
          claim_id: Faker::Number.number(digits: 7),
          original_source: "CP",
          decision_review_type: "HIGHER_LEVEL_REVIEW",
          veteran_last_name: "Smith",
          veteran_first_name: "John",
          veteran_participant_id: Faker::Number.number(digits: 9).to_s,
          file_number: Faker::Number.number(digits: 9).to_s,
          claimant_participant_id: Faker::Number.number(digits: 9).to_s,
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
          claim_creation_time: Time.zone.now.to_s,
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

    initialize_with { new(event_id, message_payload) }
  end
end
