# frozen_string_literal: true

shared_context "decision_review_completed_context" do
  let(:message_payload) do
    {
      "claim_id" => 1_234_567,
      "decision_review_type" => "HIGHER_LEVEL_REVIEW",
      "veteran_participant_id" => "123456789",
      "claimant_participant_id" => "01010101",
      "remand_created" => nil,
      "ep_code_category" => "NON_RATING",
      "claim_lifecycle_status" => "CLR",
      "actor_username" => "BVADWISE101",
      "actor_application" => "PASYSACCTCREATE",
      "completion_time" => "String",
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
      "remand_claim_id" => "8675309",
      "remand_contention_id" => "9035768",
      "unidentified" => true,
      "prior_rating_decision_id" => nil,
      "prior_non_rating_decision_id" => nil,
      "prior_caseflow_decision_issue_id" => nil,
      "prior_decision_rating_sn" => nil,
      "prior_decision_text" => nil,
      "prior_decision_type" => "Unknown",
      "prior_decision_source" => nil,
      "prior_decision_notification_date" => nil,
      "legacy_appeal_issue_id" => nil,
      "prior_decision_rating_profile_date" => nil,
      "soc_opt_in" => nil,
      "legacy_appeal_id" => nil
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
