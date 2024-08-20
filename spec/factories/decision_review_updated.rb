# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated, class: "Transformers::DecisionReviewUpdated" do
    event_id { nil }
    message_payload do
      base_message_payload(
         decision_review_issues_updated:[],
         decision_review_issues_removed:[],
         decision_review_issues_withdrawn:
         [],
         decision_review_issues_not_changed:[]
        )
    end

    # start traits
    # rating
    # eligible
    trait :eligible_rating_hlr_veteran_claimant do
      participant_id = Faker::Number.number(digits: 9).to_s

      message_payload do
        base_message_payload(
          participant_id: participant_id,
          decision_review_issues_created:[],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_rating_decision_id: 13,
              prior_decision_type: "Disability Evaluation",
              prior_decision_notification_date: "2023-08-01".to_date,
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ],
          decision_review_issues_withdrawn:
          [
            review_issues_withdrawn_attributes(
              prior_decision_notification_date: "2023-08-01".to_date,
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes,
            review_issues_created_attributes(
              contention_action: "NONE",
              contention_id: nil,
              unidentified: true
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_decision_text: "Service connection for tetnus denied (UPDATED)",
              prior_decision_type: "Disability Evaluation",
              prior_decision_notification_date: "2023-08-02".to_date,
              prior_decision_date: "2023-08-01".to_date
            )
          ],
          decision_review_issues_withdrawn:
          [
            review_issues_withdrawn_attributes(
              prior_decision_notification_date: "2023-08-01".to_date,
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ]
        )
      end
    end
    trait :eligible_rating_hlr_without_prior_decision_date do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes(
              prior_decision_date: nil
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_decision_date: nil
            )
          ],
          decision_review_issues_removed:
          [
            review_issues_removed_attributes(
              prior_decision_date: nil
            )
          ],
          decision_review_issues_withdrawn:
          [
            review_issues_withdrawn_attributes(
              prior_decision_date: nil
            )
          ],
          decision_review_issues_not_changed:[
            review_issues_not_changed_attributes(
              prior_decision_date: nil
            )
          ]
        )
      end
    end
    trait :test do
      message_payload do
        base_message_payload(
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:[],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_legacy do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes(
              eligibility_result: "ELIGIBLE_LEGACY",
              legacy_appeal_id: "LEGACYID",
              legacy_appeal_issue_id: 1
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              eligibility_result: "ELIGIBLE_LEGACY",
              legacy_appeal_id: "LEGACYID",
              legacy_appeal_issue_id: 1
            )
          ],
          decision_review_issues_removed:
          [
            review_issues_removed_attributes(
              eligibility_result: "ELIGIBLE_LEGACY",
              legacy_appeal_id: "LEGACYID",
              legacy_appeal_issue_id: 1
            )
          ],
          decision_review_issues_withdrawn:
          [
            review_issues_withdrawn_attributes(
              eligibility_result: "ELIGIBLE_LEGACY",
              legacy_appeal_id: "LEGACYID",
              legacy_appeal_issue_id: 1
            )
          ],
          decision_review_issues_not_changed:[
            review_issues_not_changed_attributes(
              eligibility_result: "ELIGIBLE_LEGACY",
              legacy_appeal_id: "LEGACYID",
              legacy_appeal_issue_id: 1
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr_time_override do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes(
              prior_rating_decision_id: 13,
              time_override: true,
              time_override_reason: "good cause exemption",
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_rating_decision_id: 13,
              time_override: true,
              time_override_reason: "good cause exemption",
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ],
          decision_review_issues_removed:
          [
            review_issues_removed_attributes(
              prior_rating_decision_id: 13,
              time_override: true,
              time_override_reason: "good cause exemption",
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ],
          decision_review_issues_withdrawn:
          [
            review_issues_withdrawn_attributes(
              prior_rating_decision_id: 13,
              time_override: true,
              time_override_reason: "good cause exemption",
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ],
          decision_review_issues_not_changed:[
            review_issues_not_changed_attributes(
              prior_rating_decision_id: 13,
              time_override: true,
              time_override_reason: "good cause exemption",
              prior_decision_diagnostic_code: "5008",
              prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00"
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr_with_two_issues do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes(
              contention_id: nil,
              prior_rating_decision_id: 12,
              prior_decision_diagnostic_code: "5008"
            ),
            review_issues_created_attributes(
              contention_action: "NONE",
              contention_id: nil,
              prior_rating_decision_id: 11,
              prior_decision_diagnostic_code: "5008"
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_rating_decision_id: 13,
              prior_decision_text: "Service connection for tetnus denied (UPDATED)",
              prior_decision_type: "Disability Evaluation",
              prior_decision_diagnostic_code: "5008"
            )
            review_issues_updated_attributes(
              prior_rating_decision_id: 14,
              prior_decision_text: "Service connection for tetnus denied (UPDATED)",
              prior_decision_type: "Disability Evaluation",
              prior_decision_diagnostic_code: "5008"
            )
          ],
          decision_review_issues_removed:
          [
            review_issues_removed_attributes(
              prior_rating_decision_id: 10,
              prior_decision_text: "Service connection for tetnus denied (WILL BE REMOVED)"
            ),
            review_issues_removed_attributes(
              prior_rating_decision_id: 9,
              prior_decision_text: "Service connection for tetnus denied (WILL BE REMOVED)"
            )
          ],
          decision_review_issues_withdrawn:

          [
            review_issues_withdrawn_attributes(
              prior_rating_decision_id: 7,
              prior_decision_text: "Service connection for tetnus denied (WILL BE WITHDRAWN)"
            ),
            review_issues_withdrawn_attributes(
              prior_rating_decision_id: 8,
              prior_decision_text: "Service connection for tetnus denied (WILL BE WITHDRAWN)"
            )
          ]
        )
      end
    end

    trait :eligible_rating_hlr_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_legacy do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_time_override do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_decision_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_legacy do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_time_override do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_rating_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_unidentified_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_unidentified_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_unidentified_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end
    trait :eligible_rating_hlr_unidentified_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_unidentified_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_rating_hlr_unidentified do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_unidentified_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_unidentified_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_unidentified_non_veteran_claimant do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_unidentified do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_without_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_legacy do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_legacy do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_unidentified_without_prior_decision_date do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_decision_issue_prior_nonrating_hlr_time_override do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_time_override do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_with_two_issues do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :eligible_nonrating_hlr_with_decision_source do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end
    ## end of eligible

    # start of ineligible
    trait :ineligible_rating_hlr_contested_with_additional_issue do
      message_payload do
        base_message_payload(
          decision_review_issues_created:
          [
            review_issues_created_attributes(
              prior_rating_decision_id: 13,
              prior_decision_diagnostic_code: "5008",
              eligibility_result: "CONTESTED"
            ),
            review_issues_created_attributes(
              contention_action: "NONE",
              prior_rating_decision_id: 13,
              prior_decision_diagnostic_code: "5008",
              eligibility_result: "CONTESTED"
            )
          ],
          decision_review_issues_updated:
          [
            review_issues_updated_attributes(
              prior_rating_decision_id: 14,
              prior_decision_diagnostic_code: "5008",
              prior_decision_text: "Service connection for tetnus denied (UPDATE)",
              eligibility_result: "CONTESTED"
            ),
            review_issues_updated_attributes(
              prior_rating_decision_id: 15,
              prior_decision_diagnostic_code: "5008",
              prior_decision_text: "Service connection for tetnus denied (ADDITIONAL UPDATE)",
              eligibility_result: "CONTESTED"
            ),

          ],
          decision_review_issues_removed:
          [
            review_issues_removed_attributes(
              prior_rating_decision_id: 10,
              prior_decision_text: "Service connection for tetnus denied (WILL BE REMOVED))",
            ),
            review_issues_removed_attributes(
              prior_rating_decision_id: 9,
              prior_decision_text: "Service connection for tetnus denied (WILL BE REMOVED AFTER)",
            )
          ],
          decision_review_issues_withdrawn:

          [
            review_issues_withdrawn_attributes(
              prior_rating_decision_id: 7,
              prior_decision_text: "Service connection for tetnus denied (WILL BE WITHDRAWN)",
              eligibility_result: "CONTESTED"
            ),
            review_issues_withdrawn_attributes(
              prior_rating_decision_id: 8,
              prior_decision_text: "Service connection for tetnus denied (WILL BE WITHDRAWN)",
              eligibility_result: "CONTESTED"
            )
          ],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_hlr_without_ri_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_with_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_contested do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_time_restriction_untimely do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_time_restriction_before_ama do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_no_soc_ssoc do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_legacy_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_legacy_time_restriction do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_pending_supplemental do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_pending_hlr_without_ri_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_with_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_time_restriction_untimely do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_time_restriction_before_ama do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_no_soc_ssoc do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_pending_legacy_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_legacy_time_restriction do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_pending_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_pending_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_pending_supplemental do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_hlr_without_ri_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_with_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_time_restriction_untimely do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_time_restriction_before_ama do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_no_soc_ssoc do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_legacy_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_legacy_time_restriction do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_pending_supplemental do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_completed_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_hlr_completed_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_completed_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_rating_decision_hlr_completed_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_completed_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_rating_hlr_completed_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_hlr_without_ri_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_with_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_contested do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_contested_with_additional_issue do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_pending_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_pending_hlr_without_ri_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_with_contention_id do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_time_restriction_untimely do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_time_restriction_before_ama do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_no_soc_ssoc do
       message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_pending_legacy_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_legacy_time_restriction do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_time_restriction_untimely do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_time_restriction_before_ama do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_no_soc_ssoc do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_legacy_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_pending_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_pending_supplemental do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_legacy_time_restriction do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_completed_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_nonrating_hlr_completed_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_pending_supplemental do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_completed_hlr do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end

    trait :ineligible_decision_issue_prior_nonrating_hlr_completed_board_appeal do
      message_payload do
        base_message_payload(
          # decision_review_issues_created:[],
          decision_review_issues_updated:[],
          decision_review_issues_removed:[],
          decision_review_issues_withdrawn:
          [],
          decision_review_issues_not_changed:[]
        )
      end
    end
    ## end of ineligible

    trait :rating_hlr_non_veteran_claimant do
      message_payload do
        base_message_payload(
          decision_review_issues_updated:[review_issues_updated_attributes(eligible: false, unidentified: true)]
        )
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
    veteran_participant_id: args[:participant_id] || Faker::Number.number(digits: 9).to_s,
    file_number: Faker::Number.number(digits: 9).to_s,
    claimant_participant_id: args[:participant_id] || Faker::Number.number(digits: 9).to_s,
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
    decision_review_issues_created:args[:decision_review_issues_created] || [review_issues_created_attributes],
    decision_review_issues_updated:args[:decision_review_issues_updated] || [review_issues_updated_attributes],
    decision_review_issues_removed:args[:decision_review_issues_removed] || [review_issues_removed_attributes],
    decision_review_issues_withdrawn:
    args[:decision_review_issues_withdrawn] || [review_issues_withdrawn_attributes],
    decision_review_issues_not_changed:args[:decision_review_issues_not_changed] || [review_issues_not_changed_attributes]
  }
end

def base_review_issue
  {
    decision_review_issue_id: 22,
    contention_action: "ADD_CONTENTION",
    reason_for_contention_action: "NEWLY_ELIGIBLE",
    contention_id: 710_002_659,
    associated_caseflow_request_issue_id: nil,
    unidentified: false,
    prior_rating_decision_id: nil,
    prior_non_rating_decision_id: nil,
    prior_caseflow_decision_issue_id: nil,
    prior_decision_text: "Service connection for tetnus denied",
    prior_decision_type: "Unknown",
    prior_decision_source: nil,
    prior_decision_notification_date: "2023-08-01".to_date,
    prior_decision_date: "2023-07-01".to_date,
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
    prior_decision_rating_profile_date: "2017-02-07T07:21:24+00:00",
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
  base_review_issue.merge(**args,
                          contention_action: "UPDATE_CONTENTION")
end

def review_issues_removed_attributes(**args)
  base_review_issue.merge(**args,
                          contention_action: "DELETE_CONTENTION",
                          reason_for_contention_action: "REMOVED_SELECTED",
                          removed: true)
end

def review_issues_withdrawn_attributes(**args)
  base_review_issue.merge(**args,
                          contention_action: "DELETE_CONTENTION",
                          reason_for_contention_action: "WITHDRAWN_SELECTED",
                          withdrawn: true)
end

def review_issues_not_changed_attributes(**args)
  base_review_issue.merge(**args,
                          contention_action: "NONE",
                          reason_for_contention_action: "NO_CHANGES")
end
