# frozen_string_literal: true

shared_context "decision_review_completed_context" do
  let(:message_payload) do
    {
      "claim_id" => 1_234_567,
      "original_source" => "CP",
      "decision_review_type" => "HIGHER_LEVEL_REVIEW",
      "veteran_first_name" => "BROCK",
      "veteran_last_name" => "PURDY",
      "veteran_participant_id" => "123456789",
      "file_number" => "1011121314",
      "claimant_participant_id" => "01010101",
      "ep_code" => "030HLRNR",
      "ep_code_category" => "NON_RATING",
      "claim_received_date" => "2023-08-25",
      "claim_lifecycle_status" => "CLR",
      "payee_code" => "00",
      "modifier" => "030",
      "originated_from_vacols_issue" => nil,
      "limited_poa_code" => nil,
      "informal_conference_requested" => false,
      "informal_conference_tracked_item_id" => nil,
      "same_station_review_requested" => false,
      "claim_creation_time" => "2023-08-25",
      "actor_username" => "BVADWISE101",
      "actor_station" => "316",
      "actor_application" => "PASYSACCTCREATE",
      "completion_time" => "2023-08-25",
      "remand_created" => false,
      "auto_remand" => false,
      "decision_review_issues_completed" => decision_review_issues_completed
    }
  end

  let(:decision_review_issues_completed) do
    [
      completed_decision_review_issue,
      canceled_decision_review_issue
    ]
  end

  let(:completed_decision_review_issue) do
    base_decision_review_issue.merge(
      "contention_id" => 345_456_567,
      "decision_review_issue_id" => 1,
      "decision" => completed_decision
    )
  end

  let(:canceled_decision_review_issue) do
    base_decision_review_issue.merge(
      "contention_id" => 987_876_765,
      "decision_review_issue_id" => 9,
      "decision" => nil
    )
  end

  let(:completed_decision) do
    base_decision.merge(
      "contention_id" => 8_342_759,
      "disposition" => "Approved"
    )
  end

  let(:decision_with_invalid_attr_types) do
    base_decision.merge(
      "contention_id" => "87654"
    )
  end

  let(:decision_with_invalid_attr_names) do
    base_decision.merge(
      "invalid_attr" => "key",
      "second_invalid_attr" => 44_494
    )
  end

  let(:decision_with_missing_attribute) do
    base_decision.except("disposition")
  end

  let(:base_decision_review_issue) do
    {
      "decision_review_issue_id" => 1,
      "contention_id" => 2,
      "associated_caseflow_request_issue_id" => nil,
      "unidentified" => true,
      "prior_rating_decision_id" => nil,
      "prior_non_rating_decision_id" => nil,
      "prior_caseflow_decision_issue_id" => nil,
      "prior_decision_rating_sn" => nil,
      "prior_decision_text" => nil,
      "prior_decision_type" => "Unknown",
      "prior_decision_source" => nil,
      "prior_decision_notification_date" => nil,
      "prior_decision_date" => nil,
      "prior_decision_diagnostic_code" => nil,
      "prior_decision_rating_percentage" => nil,
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
      "original_caseflow_request_issue_id" => nil
    }
  end

  let(:base_decision) do
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
