# frozen_string_literal: true

shared_context "decision_review_updated_context" do
  let(:message_payload) do
    {
      "claim_id" => 1_234_567,
      "original_source" => "CP",
      "decision_review_type" => "HigherLevelReview",
      "veteran_first_name" => "John",
      "veteran_last_name" => "Smith",
      "veteran_participant_id" => "123456789",
      "file_number" => "123456789",
      "claimant_participant_id" => "01010101",
      "ep_code" => "030HLRR",
      "ep_code_category" => "RATING",
      "claim_received_date" => "2023-08-25",
      "claim_lifecycle_status" => "Ready for Decision",
      "payee_code" => "00",
      "modifier" => "030",
      "originated_from_vacols_issue" => nil,
      "limited_poa_code" => "",
      "tracked_item_action" => "TRACKED",
      "informal_conference_requested" => false,
      "informal_conference_tracked_item_id" => "1",
      "same_station_review_requested" => false,
      "update_time" => Date.new(2022, 1, 2).to_time.to_s,
      "claim_creation_time" => Date.new(2022, 1, 1).to_time.to_s,
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

  let(:base_decision_review_issue) do
    {
      "associated_caseflow_request_issue_id" => nil,
      "decision_review_issue_id" => 1,
      "unidentified" => true,
      "prior_rating_decision_id" => nil,
      "prior_non_rating_decision_id" => nil,
      "prior_caseflow_decision_issue_id" => nil,
      "prior_decision_text" => nil,
      "prior_decision_type" => "Unknown",
      "prior_decision_source" => nil,
      "prior_decision_notification_date" => nil,
      "prior_decision_date" => Date.new(2022, 1, 1).to_time.to_s,
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
      "original_caseflow_request_issue_id" => nil,
      "source_contention_id_for_remand" => nil,
      "removed" => false,
      "withdrawn" => false,
      "decision" => nil
    }
  end

  let(:decision_review_issues_created) do
    [
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "ADD_CONTENTION",
        "reason_for_contention_action" => "NEW_ELIGIBLE_ISSUE",
        "prior_decision_text" => "An unidentified issue added during the edit"
      ),
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "NO_CHANGES",
        "prior_decision_text" => "An unidentified issue added during the edit"
      )
    ]
  end

  let(:decision_review_issues_updated) do
    [
      base_decision_review_issue.merge(
        "contention_id" => 123_456_791,
        "contention_action" => "UPDATE_CONTENTION",
        "reason_for_contention_action" => "PRIOR_DECISION_TEXT_CHANGED",
        "unidentified" => false,
        "prior_non_rating_decision_id" => 13,
        "prior_decision_text" => "DIC: Service connection denied (UPDATED)",
        "prior_decision_type" => "DIC:",
        "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
        "time_override" => true,
        "time_override_reason" => "good cause exemption"
      ),
      base_decision_review_issue.merge(
        "eligible" => false,
        "eligibility_result" => "TIME_RESTRICTION",
        "decision_review_issue_id" => nil,
        "contention_id" => nil,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "PRIOR_DECISION_TEXT_CHANGED",
        "unidentified" => false,
        "prior_non_rating_decision_id" => 13,
        "prior_decision_text" => "DIC: Service connection for tetnus denied",
        "prior_decision_type" => "DIC:",
        "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
        "time_override" => false
      ),
      base_decision_review_issue.merge(
        "eligible" => false,
        "eligibility_result" => "TIME_RESTRICTION",
        "decision_review_issue_id" => nil,
        "contention_id" => nil,
        "contention_action" => "DELETE_CONTENTION",
        "reason_for_contention_action" => "ELIGIBLE_TO_INELIGIBLE",
        "unidentified" => false,
        "prior_non_rating_decision_id" => 13,
        "prior_decision_text" => "DIC: Service connection for tetnus denied",
        "prior_decision_type" => "DIC:",
        "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
        "time_override" => false
      ),
      base_decision_review_issue.merge(
        "eligible" => false,
        "eligibility_result" => "TIME_RESTRICTION",
        "decision_review_issue_id" => nil,
        "contention_id" => nil,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "INELIGIBLE_REASON_CHANGED",
        "unidentified" => false,
        "prior_non_rating_decision_id" => 13,
        "prior_decision_text" => "DIC: Service connection for tetnus denied",
        "prior_decision_type" => "DIC:",
        "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
        "time_override" => false
      ),
      base_decision_review_issue.merge(
        "contention_id" => 123_456_791,
        "contention_action" => "ADD_CONTENTION",
        "reason_for_contention_action" => "INELIGIBLE_TO_ELIGIBLE",
        "unidentified" => false,
        "prior_non_rating_decision_id" => 13,
        "prior_decision_text" => "DIC: Service connection for tetnus denied",
        "prior_decision_type" => "DIC:",
        "prior_decision_source" => "CORP_AWARD_ATTORNEY_FEE",
        "time_override" => true,
        "time_override_reason" => "good cause exemption"
      )
    ]
  end

  let(:decision_review_issues_removed) do
    [
      base_decision_review_issue.merge(
        "contention_id" => 328_253,
        "contention_action" => "DELETE_CONTENTION",
        "reason_for_contention_action" => "REMOVED_SELECTED",
        "prior_decision_text" => "The second unidentified issue (will be removed)",
        "removed" => true
      )
    ]
  end

  let(:decision_review_issues_withdrawn) do
    [
      base_decision_review_issue.merge(
        "contention_id" => 328_252,
        "contention_action" => "DELETE_CONTENTION",
        "reason_for_contention_action" => "WITHDRAWN_SELECTED",
        "prior_decision_text" => "The first unidentified issue (will be withdrawn)",
        "withdrawn" => true
      )
    ]
  end

  let(:decision_review_issues_not_changed) do
    [
      base_decision_review_issue.merge(
        "contention_id" => 328_254,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "",
        "prior_decision_text" => "The third unidentified issue (not changed)"
      )
    ]
  end

  let(:decision) do
    {
      "contention_id" => 1_234_567,
      "disposition" => "Approved",
      "dta_error_explanation" => "None",
      "decision_source" => "Source",
      "category" => "Category",
      "decision_id" => 2,
      "decision_text" => "Decision text",
      "award_event_id" => 3,
      "rating_profile_date" => "2023-07-22",
      "decision_recorded_time" => "",
      "decision_finalized_time" => ""
    }
  end
end
