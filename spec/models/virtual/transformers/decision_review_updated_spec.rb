# frozen_string_literal: true

describe Transformers::DecisionReviewUpdated do
  subject(:decision_review_updated) { described_class.new(event_id, message_payload) }

  let(:event_id) { 13 }
  let(:message_payload) do
    {
      claim_id: 1_234_567,
      original_source: "SOURCE",
      decision_review_type: "HigherLevelReview",
      veteran_first_name: "John",
      veteran_last_name: "Smith",
      veteran_participant_id: "123456789",
      file_number: "123456789",
      claimant_participant_id: "01010101",
      ep_code: "12345",
      ep_code_category: "RATING",
      claim_received_date: "2023-08-25",
      claim_lifecycle_status: "",
      payee_code: "1",
      modifier: "",
      originated_from_vacols_issue: false,
      limited_poa_code: "",
      tracked_item_action: "TRACKED",
      informal_conference_requested: false,
      informal_conference_tracked_item_id: "1",
      same_station_review_requested: false,
      update_time: "string",
      claim_creation_time: "",
      actor_username: "BVADWISE101",
      actor_station: "101",
      actor_application: "PASYSACCTCREATE",
      auto_remand: false,
      decision_review_issues_created: [],
      decision_review_issues_updated: [decision_review_issue_updated],
      decision_review_issues_removed: [],
      decision_review_issues_withdrawn: [],
      decision_review_issues_not_changed: []
    }
  end
  let(:decision_review_issue_updated) do
    {
      contention_id: 123_456_791,
      original_source: "SOURCE",
      contention_action: "Action",
      associated_caseflow_request_issue_id: nil,
      unidentified: false,
      prior_rating_decision_id: nil,
      prior_non_rating_decision_id: 13,
      prior_caseflow_decision_issue_id: nil,
      prior_decision_text: "DIC: Service connection for tetnus denied",
      prior_decision_type: "DIC:",
      prior_decision_source: "CORP_AWARD_ATTORNEY_FEE",
      prior_decision_notification_date: nil,
      prior_decision_date: nil,
      prior_decision_diagnostic_code: nil,
      prior_decision_rating_percentage: nil,
      prior_decision_rating_sn: nil,
      eligible: true,
      eligibility_result: "ELIGIBLE",
      time_override: true,
      time_override_reason: "good cause exemption",
      contested: nil,
      soc_opt_in: nil,
      legacy_appeal_id: nil,
      legacy_appeal_issue_id: nil,
      prior_decision_award_event_id: nil,
      prior_decision_rating_profile_date: nil,
      source_claim_id_for_remand: nil,
      source_contention_id_for_remand: nil,
      removed: false,
      withdrawn: false
    }
  end

  let(:decision) do
    {
      contention_id: 1_234_567,
      disposition: "Approved",
      dta_error_explanation: "None",
      decision_source: "Source",
      category: "Category",
      decision_id: 2,
      decision_text: "Decision text",
      award_event_id: 3,
      rating_profile_date: "2023-07-22",
      decision_recorded_time: "",
      decision_finalized_time: ""
    }
  end

  describe "#initialize" do
    it "sets the event id" do
      expect(decision_review_updated.event_id).to eq(13)
    end

    it "validates the message_payload" do
      expect { decision_review_updated }.not_to raise_error
    end

    it "sets the instance variables for DecisionReviewUpdated" do
      expect(subject.claim_id).to eq(message_payload[:claim_id])
      expect(subject.original_source).to eq(message_payload[:original_source])
      expect(subject.decision_review_type).to eq(message_payload[:decision_review_type])
      expect(subject.veteran_participant_id).to eq(message_payload[:veteran_participant_id])
      expect(subject.file_number).to eq(message_payload[:file_number])
      expect(subject.claimant_participant_id).to eq(message_payload[:claimant_participant_id])
      expect(subject.originated_from_vacols_issue).to eq(message_payload[:originated_from_vacols_issue])
      expect(subject.tracked_item_action).to eq(message_payload[:tracked_item_action])
      expect(subject.informal_conference_requested).to eq(message_payload[:informal_conference_requested])
      expect(subject.informal_conference_tracked_item_id).to eq(message_payload[:informal_conference_tracked_item_id])
      expect(subject.same_station_review_requested).to eq(message_payload[:same_station_review_requested])
      expect(subject.update_time).to eq(message_payload[:update_time])
      expect(subject.actor_username).to eq(message_payload[:actor_username])
      expect(subject.actor_station).to eq(message_payload[:actor_station])
      expect(subject.actor_application).to eq(message_payload[:actor_application])
      expect(subject.auto_remand).to eq(message_payload[:auto_remand])
      expect(subject.decision_review_issues_updated.size).to eq(message_payload[:decision_review_issues_updated].count)
    end

    it "instantiates a DecisionReviewIssueUpdated object" do
      subject.decision_review_issues_updated.each do |issue|
        expect(issue).to be_an_instance_of(DecisionReviewIssueUpdated)
      end
    end

    it "set instance variables for DecisionReviewIssueUpdated" do
      subject.decision_review_issues_updated.each do |issue|
        expect(issue.contention_id).to eq(decision_review_issue_updated[:contention_id])
        expect(issue.original_source).to eq(decision_review_issue_updated[:original_source])
        expect(issue.contention_action).to eq(decision_review_issue_updated[:contention_action])
        expect(issue.associated_caseflow_request_issue_id).to eq(
          decision_review_issue_updated[:associated_caseflow_request_issue_id]
        )
        expect(issue.unidentified).to eq(decision_review_issue_updated[:unidentified])
        expect(issue.prior_rating_decision_id).to eq(decision_review_issue_updated[:prior_rating_decision_id])
        expect(issue.prior_non_rating_decision_id).to eq(decision_review_issue_updated[:prior_non_rating_decision_id])
        expect(issue.prior_caseflow_decision_issue_id).to eq(
          decision_review_issue_updated[:prior_caseflow_decision_issue_id]
        )
        expect(issue.prior_decision_text).to eq(decision_review_issue_updated[:prior_decision_text])
        expect(issue.prior_decision_type).to eq(decision_review_issue_updated[:prior_decision_type])
        expect(issue.prior_decision_source).to eq(decision_review_issue_updated[:prior_decision_source])
        expect(issue.prior_decision_notification_date).to eq(
          decision_review_issue_updated[:prior_decision_notification_date]
        )
        expect(issue.prior_decision_date).to eq(decision_review_issue_updated[:prior_decision_date])
        expect(issue.prior_decision_diagnostic_code).to eq(
          decision_review_issue_updated[:prior_decision_diagnostic_code]
        )
        expect(issue.prior_decision_rating_percentage).to eq(
          decision_review_issue_updated[:prior_decision_rating_percentage]
        )
        expect(issue.prior_decision_rating_sn).to eq(decision_review_issue_updated[:prior_decision_rating_sn])
        expect(issue.eligible).to eq(decision_review_issue_updated[:eligible])
        expect(issue.eligibility_result).to eq(decision_review_issue_updated[:eligibility_result])
        expect(issue.time_override).to eq(decision_review_issue_updated[:time_override])
        expect(issue.time_override_reason).to eq(decision_review_issue_updated[:time_override_reason])
        expect(issue.contested).to eq(decision_review_issue_updated[:contested])
        expect(issue.soc_opt_in).to eq(decision_review_issue_updated[:soc_opt_in])
        expect(issue.legacy_appeal_id).to eq(decision_review_issue_updated[:legacy_appeal_id])
        expect(issue.legacy_appeal_issue_id).to eq(decision_review_issue_updated[:legacy_appeal_issue_id])
        expect(issue.prior_decision_award_event_id).to eq(decision_review_issue_updated[:prior_decision_award_event_id])
        expect(issue.prior_decision_rating_profile_date).to eq(
          decision_review_issue_updated[:prior_decision_rating_profile_date]
        )
        expect(issue.source_claim_id_for_remand).to eq(decision_review_issue_updated[:source_claim_id_for_remand])
        expect(issue.source_contention_id_for_remand).to eq(
          decision_review_issue_updated[:source_contention_id_for_remand]
        )
        expect(issue.removed).to eq(decision_review_issue_updated[:removed])
        expect(issue.withdrawn).to eq(decision_review_issue_updated[:withdrawn])
      end
    end
  end
end
