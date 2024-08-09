# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated, class: "Transformers::DecisionReviewUpdated" do
    event_id { nil }
    
    trait :eligible_rating_hlr do
      decision_review_issues_created do
        [
          review_issues_created_attributes(
            contention_action: "ADD_CONTENTION- TEST",
            prior_rating_decision_id: 13,
          )
        ]
      end
      decision_review_issues_removed do
        review_issues_removed_attributes(
          contention_action: "DELETE_CONTENTION"
        )
      end
      decision_review_issues_withdrawn do
        review_issues_withdrawn_attributes(
          contention_action: "DELETE_CONTENTION"
        )
      end

    end

    trait :eligible_rating_hlr_veteran_claimant do
      rating_hlr_veteran_claimant
    end

    trait :eligible_rating_hlr_non_veteran_claimant do
      rating_hlr_non_veteran_claimant
      eligible_rating_hlr
    end

    trait :rating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload
      end
    end

    trait :rating_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s

      message_payload do
        base_message_payload(participant_id: participant_id)
      end
    end

    initialize_with { new(event_id, message_payload) }
  end
end

def base_message_payload(**args)
  {
    claim_id: Faker::Number.number(digits: 7),
    original_source: "CP",
    decision_review_type: "HIGHER_LEVEL_REVIEW",
    veteran_last_name: "Smith",
    veteran_first_name: "John",
    veteran_participant_id: args["participant_id"] || Faker::Number.number(digits: 9).to_s,
    file_number: Faker::Number.number(digits: 9).to_s,
    claimant_participant_id: args["participant_id"] || Faker::Number.number(digits: 9).to_s,
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
    decision_review_issues_created: [review_issues_created_attributes],
    decision_review_issues_updated: [review_issues_updated_attributes],
    decision_review_issues_removed: [review_issues_removed_attributes],
    decision_review_issues_withdrawn: [review_issues_withdrawn_attributes],
    decision_review_issues_not_changed: [review_issues_not_changed_attributes]
  }
end

def base_review_issue
  {
    decision_review_issue_id: 22,
    contention_action: "ADD_CONTENTION",
    contention_id: 710_002_659,
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
end

def review_issues_created_attributes(**args)
  base_review_issue.merge(args)
end

def review_issues_updated_attributes(**args)
  base_review_issue.merge(args)
end

def review_issues_removed_attributes(**args)
  base_review_issue.merge(args)
end

def review_issues_withdrawn_attributes(**args)
  base_review_issue.merge(args)
end

def review_issues_not_changed_attributes(**args)
  base_review_issue.merge(args)
end
