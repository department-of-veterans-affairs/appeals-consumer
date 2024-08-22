# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated,
          class: "Transformers::DecisionReviewUpdated" do
    nonrating_hlr_veteran_claimant

    transient do
      decision_review_issues_created do
        [
          {
            "decision_review_issue_id" => 22,
            "contention_id" => 710_002_659,
            "contention_action" => "ADD_CONTENTION",
            "reason_for_contention_action" => "NEWLY_ELIGIBLE",
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Unknown",
            "prior_decision_source" => nil,
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_sn" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_rating_profile_date" => nil,
            "source_claim_id_for_remand" => nil,
            "source_contention_id_for_remand" => nil,
            "removed" => false,
            "withdrawn" => false,
            "decision" => nil
          }
        ]
      end
      decision_review_issues_updated do
        [
          {
            "decision_review_issue_id" => 22,
            "contention_id" => 710_002_659,
            "contention_action" => "ADD_CONTENTION",
            "reason_for_contention_action" => "NEWLY_ELIGIBLE",
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Unknown",
            "prior_decision_source" => nil,
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_sn" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_rating_profile_date" => nil,
            "source_claim_id_for_remand" => nil,
            "source_contention_id_for_remand" => nil,
            "removed" => false,
            "withdrawn" => false,
            "decision" => nil
          },
          {
            "decision_review_issue_id" => 22,
            "contention_id" => 710_002_659,
            "contention_action" => "ADD_CONTENTION",
            "reason_for_contention_action" => "NEWLY_ELIGIBLE",
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Unknown",
            "prior_decision_source" => nil,
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_sn" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => false,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_rating_profile_date" => nil,
            "source_claim_id_for_remand" => nil,
            "source_contention_id_for_remand" => nil,
            "removed" => false,
            "withdrawn" => false,
            "decision" => nil
          }
        ]
      end
      decision_review_issues_removed { [] }
      decision_review_issues_withdrawn { [] }
      decision_review_issues_not_changed { [] }
    end

    trait :nonrating_hlr_veteran_claimant do
      message_payload do
        {
          "claim_id" => Faker::Number.number(digits: 7),
          "original_source" => "CP",
          "decision_review_type" => "HIGHER_LEVEL_REVIEW",
          "veteran_last_name" => "Smith",
          "veteran_first_name" => "John",
          "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
          "file_number" => Faker::Number.number(digits: 9).to_s,
          "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
          "ep_code" => "030HLRNR",
          "ep_code_category" => "NON_RATING",
          "claim_received_date" => "2023-08-25",
          "claim_lifecycle_status" => "Ready to Work",
          "payee_code" => "00",
          "modifier" => "01",
          "originated_from_vacols_issue" => false,
          "limited_poa_code" => nil,
          "tracked_item_action" => "ADD_TRACKED_ITEM",
          "informal_conference_tracked_item_id" => "1",
          "informal_conference_requested" => false,
          "same_station_review_requested" => false,
          "update_time" => "1_722_435_298_953",
          "claim_creation_time" => Time.zone.now.to_s,
          "actor_username" => "BVADWISE101",
          "actor_station" => "101",
          "actor_application" => "PASYSACCTCREATE",
          "auto_remand" => false,
          "decision_review_issues_created" => decision_review_issues_created,
          "decision_review_issues_updated" => decision_review_issues_updated,
          "decision_review_issues_removed" => decision_review_issues_removed,
          "decision_review_issues_withdrawn" => decision_review_issues_withdrawn,
          "decision_review_issues_not_changed" => decision_review_issues_not_changed
        }
      end
      event_id { nil }
    end

    trait :ineligible_nonrating_hlr_pending_legacy_appeal do
      decision_review_issues_created do
        [
          {
            "decision_review_issue_id" => 22,
            "contention_id" => 710_002_659,
            "contention_action" => "ADD_CONTENTION",
            "reason_for_contention_action" => "NEWLY_ELIGIBLE",
            "associated_caseflow_request_issue_id" => nil,
            "unidentified" => false,
            "prior_rating_decision_id" => nil,
            "prior_non_rating_decision_id" => nil,
            "prior_caseflow_decision_issue_id" => nil,
            "prior_decision_text" => "Service connection for tetnus denied",
            "prior_decision_type" => "Unknown",
            "prior_decision_source" => nil,
            "prior_decision_notification_date" => nil,
            "prior_decision_date" => nil,
            "prior_decision_diagnostic_code" => nil,
            "prior_decision_rating_percentage" => nil,
            "prior_decision_rating_sn" => nil,
            "eligible" => true,
            "eligibility_result" => "ELIGIBLE",
            "time_override" => nil,
            "time_override_reason" => nil,
            "contested" => nil,
            "soc_opt_in" => true,
            "legacy_appeal_id" => nil,
            "legacy_appeal_issue_id" => nil,
            "prior_decision_award_event_id" => nil,
            "prior_decision_rating_profile_date" => nil,
            "source_claim_id_for_remand" => nil,
            "source_contention_id_for_remand" => nil,
            "removed" => false,
            "withdrawn" => false,
            "decision" => nil
          }
        ]
      end
    end
    initialize_with { new(event_id, message_payload) }
  end
end
