# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe Transformers::DecisionReviewUpdated do
  subject(:decision_review_updated) { described_class.new(event_id, message_payload) }

  include_context "decision_review_updated_context"

  let(:event_id) { 13 }

  context "when valid" do
    describe "#initialize" do
      it "sets the event id" do
        expect(decision_review_updated.event_id).to eq(13)
      end

      it "validates the message_payload" do
        expect { decision_review_updated }.not_to raise_error
      end

      it "sets the instance variables for DecisionReviewUpdated" do
        expect(subject.claim_id).to eq(message_payload["claim_id"])
        expect(subject.original_source).to eq(message_payload["original_source"])
        expect(subject.decision_review_type).to eq(message_payload["decision_review_type"])
        expect(subject.veteran_participant_id).to eq(message_payload["veteran_participant_id"])
        expect(subject.file_number).to eq(message_payload["file_number"])
        expect(subject.claimant_participant_id).to eq(message_payload["claimant_participant_id"])
        expect(subject.originated_from_vacols_issue).to eq(message_payload["originated_from_vacols_issue"])
        expect(subject.tracked_item_action).to eq(message_payload["tracked_item_action"])
        expect(subject.informal_conference_requested).to eq(message_payload["informal_conference_requested"])
        expect(subject.informal_conference_tracked_item_id).to eq(
          message_payload["informal_conference_tracked_item_id"]
        )
        expect(subject.same_station_review_requested).to eq(message_payload["same_station_review_requested"])
        expect(subject.update_time).to eq(message_payload["update_time"])
        expect(subject.actor_username).to eq(message_payload["actor_username"])
        expect(subject.actor_station).to eq(message_payload["actor_station"])
        expect(subject.actor_application).to eq(message_payload["actor_application"])
        expect(subject.auto_remand).to eq(message_payload["auto_remand"])
        expect(subject.decision_review_issues_updated.size).to eq(
          message_payload["decision_review_issues_updated"].count
        )
      end

      it "instantiates a DecisionReviewIssueUpdated object" do
        subject.decision_review_issues_updated.each do |issue|
          expect(issue).to be_an_instance_of(DecisionReviewIssueUpdated)
        end
      end
      it "sets instance variables for DecisionReviewIssueUpdated" do
        subject.decision_review_issues_updated.each.with_index do |issue, index|
          expect(issue.contention_id).to eq(decision_review_issues_updated[index]["contention_id"])
          expect(issue.contention_action).to eq(decision_review_issues_updated[index]["contention_action"])
          expect(issue.associated_caseflow_request_issue_id).to eq(
            decision_review_issues_updated[index]["associated_caseflow_request_issue_id"]
          )
          expect(issue.unidentified).to eq(decision_review_issues_updated[index]["unidentified"])
          expect(issue.prior_rating_decision_id).to eq(
            decision_review_issues_updated[index]["prior_rating_decision_id"]
          )
          expect(issue.prior_non_rating_decision_id).to eq(
            decision_review_issues_updated[index]["prior_non_rating_decision_id"]
          )
          expect(issue.prior_caseflow_decision_issue_id).to eq(
            decision_review_issues_updated[index]["prior_caseflow_decision_issue_id"]
          )
          expect(issue.prior_decision_text).to eq(decision_review_issues_updated[index]["prior_decision_text"])
          expect(issue.prior_decision_type).to eq(decision_review_issues_updated[index]["prior_decision_type"])
          expect(issue.prior_decision_source).to eq(decision_review_issues_updated[index]["prior_decision_source"])
          expect(issue.prior_decision_notification_date).to eq(
            decision_review_issues_updated[index]["prior_decision_notification_date"]
          )
          expect(issue.prior_decision_date).to eq(decision_review_issues_updated[index]["prior_decision_date"])
          expect(issue.prior_decision_diagnostic_code).to eq(
            decision_review_issues_updated[index]["prior_decision_diagnostic_code"]
          )
          expect(issue.prior_decision_rating_percentage).to eq(
            decision_review_issues_updated[index]["prior_decision_rating_percentage"]
          )
          expect(issue.prior_decision_rating_sn).to eq(
            decision_review_issues_updated[index]["prior_decision_rating_sn"]
          )
          expect(issue.eligible).to eq(decision_review_issues_updated[index]["eligible"])
          expect(issue.eligibility_result).to eq(decision_review_issues_updated[index]["eligibility_result"])
          expect(issue.time_override).to eq(decision_review_issues_updated[index]["time_override"])
          expect(issue.time_override_reason).to eq(decision_review_issues_updated[index]["time_override_reason"])
          expect(issue.contested).to eq(decision_review_issues_updated[index]["contested"])
          expect(issue.soc_opt_in).to eq(decision_review_issues_updated[index]["soc_opt_in"])
          expect(issue.legacy_appeal_id).to eq(decision_review_issues_updated[index]["legacy_appeal_id"])
          expect(issue.legacy_appeal_issue_id).to eq(decision_review_issues_updated[index]["legacy_appeal_issue_id"])
          expect(issue.prior_decision_award_event_id).to eq(
            decision_review_issues_updated[index]["prior_decision_award_event_id"]
          )
          expect(issue.prior_decision_rating_profile_date).to eq(
            decision_review_issues_updated[index]["prior_decision_rating_profile_date"]
          )
          expect(issue.source_claim_id_for_remand).to eq(
            decision_review_issues_updated[index]["source_claim_id_for_remand"]
          )
          expect(issue.original_caseflow_request_issue_id).to eq(
            decision_review_issues_updated[index]["original_caseflow_request_issue_id"]
          )
          expect(issue.source_contention_id_for_remand).to eq(
            decision_review_issues_updated[index]["source_contention_id_for_remand"]
          )
          expect(issue.removed).to eq(decision_review_issues_updated[index]["removed"])
          expect(issue.withdrawn).to eq(decision_review_issues_updated[index]["withdrawn"])
        end
      end
    end
    describe "#decision_review_issues" do
      it "returns all decision_review_issues" do
        expect(subject.decision_review_issues.count).to eq 10
        expect(subject.decision_review_issues.class).to eq(Array)
      end
    end
  end

  context "when invalid" do
    context "when all issues are empty other than decision_review_issues_not_changed" do
      before do
        message_payload["decision_review_issues_created"] = []
        message_payload["decision_review_issues_updated"] = []
        message_payload["decision_review_issues_removed"] = []
        message_payload["decision_review_issues_withdrawn"] = []
      end

      it "raises ArgumentError" do
        error_message =
          "Transformers::DecisionReviewUpdated: Message payload must include at least one decision review issue updated"
        expect { subject }.to raise_error(ArgumentError, error_message)
      end
    end
  end

  context "when a decision exist" do
    before do
      message_payload["decision_review_issues_updated"][0]["decision"] = decision
    end

    it "creates decision" do
      decision = subject.decision_review_issues_updated[0].decision
      expect(decision).to be_an_instance_of(Decision)
    end

    it "creates decision attributes" do
      created_decision = subject.decision_review_issues_updated[0].decision

      expect(created_decision.contention_id).to eq(decision["contention_id"])
      expect(created_decision.disposition).to eq(decision["disposition"])
      expect(created_decision.dta_error_explanation).to eq(decision["dta_error_explanation"])
      expect(created_decision.decision_source).to eq(decision["decision_source"])
      expect(created_decision.category).to eq(decision["category"])
      expect(created_decision.decision_id).to eq(decision["decision_id"])
      expect(created_decision.award_event_id).to eq(decision["award_event_id"])
      expect(created_decision.rating_profile_date).to eq(decision["rating_profile_date"])
      expect(created_decision.decision_recorded_time).to eq(decision["decision_recorded_time"])
      expect(created_decision.decision_finalized_time).to eq(decision["decision_finalized_time"])
    end
  end
end
