# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_completed, class: "Transformers::DecisionReviewCompleted" do
    event_id { nil }
    message_payload do
      base_completed_message_payload
    end

    # start traits
    trait :test do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
            [
              review_issues_completed_attributes(
                "decision_review_issue_id" => 777,
                decision: base_decision(
                  disposition: "remand"
                )
              )
            ]
        )
      end
    end
    # unidentified
    ## non_rating
    ### completed
    ### cancelled
    ## rating
    ### completed
    #### closed
    trait :eligible_rating_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
            [
              rating_review_issues_completed_attributes(
                "prior_decision_type" => "Disability Evaluation",
                decision: base_decision
              )
            ]
        )
      end
    end

    trait :eligible_rating_hlr_non_veteran_claimant do
      message_payload do
        base_completed_message_payload
      end
    end

    ######### DONT NEEED ########??????????????????
    trait :eligible_rating_hlr_without_prior_decision_date do
      :empty
    end

    ### cancelled
    # idtentifed
    ## non_rating
    ### completed
    #### closed
    trait :eligible_non_rating_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s
      ep_code_category = "NON_RATING"
      message_payload do
        base_completed_message_payload(
          ep_code_category: ep_code_category,
          participant_id: participant_id,
          decision_review_issues_completed:
            [
              review_issues_completed_attributes(
                decision: base_decision(
                  ep_code_category: ep_code_category
                )
              )
            ]
        )
      end
    end
    ### cancelled
    ## rating
    ### completed
    trait :eligible_rating_hlr_legacy do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligibility_result" => "ELIGIBLE_LEGACY",
              "legacy_appeal_id" => "LEGACYID",
              "legacy_appeal_issue_id" => 1,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr_time_override do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "time_override" => true,
              "time_override_reason" => "good cause exemption",
              decision: base_decision
            )
          ]
        )
      end
    end

    ######### DONT NEEED ########??????????????????
    trait :eligible_rating_hlr_with_two_issues do
      :decision_review_completed
    end

    ######### DONT NEEED ########??????????????????
    trait :ineligible_rating_hlr_contested_with_additional_issue do
      :decision_review_completed
    end

    ######### DONT NEEED ########??????????????????
    trait :ineligible_rating_hlr_pending_hlr_without_ri_id do
      :decision_review_completed
    end

    trait :eligible_rating_hlr_with_decision_source do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_with_contention_id do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "PENDING_BOARD_APPEAL",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_contested do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "CONTESTED",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_time_restriction_untimely do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "TIME_RESTRICTION",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_time_restriction_before_ama do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "TIME_RESTRICTION",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_no_soc_ssoc do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "NO_SOC_SSOC",
              "soc_opt_in" => false,
              "legacy_appeal_id" => "LEGACYID",
              "legacy_appeal_issue_id" => 1,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_legacy_appeal do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "PENDING_LEGACY_APPEAL",
              "soc_opt_in" => true,
              "legacy_appeal_id" => "LEGACYID",
              "legacy_appeal_issue_id" => 1,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_legacy_time_restriction do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "LEGACY_TIME_RESTRICTION",
              "legacy_appeal_id" => "LEGACYID",
              "legacy_appeal_issue_id" => 1,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_hlr do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "PENDING_HLR",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_completed_hlr do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "COMPLETED_HLR",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_completed_board_appeal do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "COMPLETED_BOARD_APPEAL",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_board_appeal do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "PENDING_BOARD_APPEAL",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_supplemental do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligible" => false,
              "eligibility_result" => "PENDING_SUPPLEMENTAL",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_decision_hlr_non_veteran_claimant do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "prior_decision_rating_sn" => "1_623_547",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_decision_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              decision: base_decision
            )
          ]
        )
      end
    end

    ### cancelled
    ## invalid messages
    trait :eligible_rating_hlr_without_contention_id do
      message_payload do
        base_completed_message_payload(
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "contention_id" => nil,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_decision_hlr_without_prior_decision_date do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "prior_decision_date" => nil,
              "prior_decision_rating_sn" => "1_623_547",
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_decision_hlr_legacy do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "eligibility_result" => "ELIGIBLE_LEGACY",
              "prior_decision_rating_sn" => "1_623_547",
              "legacy_appeal_id" => "LEGACYID",
              "legacy_appeal_issue_id" => 1,
              decision: base_decision
            )
          ]
        )
      end
    end

    trait :eligible_rating_decision_hlr_time_override do
      participant_id = Faker::Number.number(digits: 9).to_s
      message_payload do
        base_completed_message_payload(
          participant_id: participant_id,
          decision_review_issues_completed:
          [
            rating_review_issues_completed_attributes(
              "prior_decision_rating_sn" => "1_623_547",
              "time_override" => true,
              "time_override_reason" => "good cause exemption",
              decision: base_decision
            )
          ]
        )
      end
    end

    initialize_with { new(event_id, message_payload) }
  end
end

# rubocop:disable Metrics/CyclomaticComplexity
def base_completed_message_payload(**args)
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
    "informal_conference_requested" => args[:informal_conference_requested] || false,
    "informal_conference_tracked_item_id" => nil,
    "same_station_review_requested" => args[:same_station_review_requested] || false,
    "claim_creation_time" => "2023-08-25",
    "actor_username" => "BVADWISE101",
    "actor_station" => "101",
    "actor_application" => "PASYSACCTCREATE",
    "completion_time" => "2023-08-25",
    "remand_created" => false,
    "auto_remand" => false,
    "decision_review_issues_completed" => args[:decision_review_issues_completed] ||
      [base_review_issues_completed]
  }
end
# rubocop:enable Metrics/CyclomaticComplexity

def base_review_issues_completed
  {
    "decision_review_issue_id" => 22,
    "contention_id" => 710_002_659,
    "associated_caseflow_request_issue_id" => nil,
    "unidentified" => false,
    "prior_rating_decision_id" => nil,
    "prior_non_rating_decision_id" => nil,
    "prior_caseflow_decision_issue_id" => nil,
    "prior_decision_text" => "Service connection for tetnus denied",
    "prior_decision_type" => "Unknown",
    "prior_decision_source" => nil,
    "prior_decision_notification_date" => "2023-08-01",
    "prior_decision_date" => "2023-07-01",
    "prior_decision_diagnostic_code" => nil,
    "prior_decision_rating_percentage" => nil,
    "prior_decision_rating_sn" => nil,
    "eligible" => true,
    "eligibility_result" => "ELIGIBLE",
    "time_override" => nil,
    "time_override_reason" => nil,
    "contested" => nil,
    "soc_opt_in" => nil,
    "legacy_appeal_id" => nil,
    "legacy_appeal_issue_id" => nil,
    "prior_decision_award_event_id" => nil,
    "prior_decision_rating_profile_date" => nil,
    "source_claim_id_for_remand" => nil,
    "source_contention_id_for_remand" => nil,
    "original_caseflow_request_issue_id" => nil,
    "decision" => nil
  }
end

def review_issues_completed_attributes(**args)
  base_review_issues_completed.merge(**args,
                                     "decision" => args[:decision] || nil)
end

def rating_review_issues_completed_attributes(**args)
  base_review_issues_completed.merge(**args,
                                    "prior_rating_decision_id" => 13,
                                    "prior_decision_type" => "Disability Evaluation",
                                    "prior_decision_diagnostic_code" => "5008",
                                    "prior_decision_rating_profile_date" => "2017-02-07T07:21:24+00:00",
                                    "decision" => args[:decision] || nil)
end

def base_decision(**args)
  {
    "contention_id" => 710_002_659,
    "disposition" => args[:disposition] || "Granted",
    "dta_error_explanation" => nil,
    "decision_source" => nil,
    "category" => args[:ep_code_category] || "rating",
    "decision_id" => nil,
    "decision_text" => nil,
    "award_event_id" => nil,
    "rating_profile_date" => nil,
    "decision_recorded_time" => "2024-11-14T00:09:00.788173Z",
    "decision_finalized_time" => "2024-11-13T17:49:57.14374Z"
  }
end
