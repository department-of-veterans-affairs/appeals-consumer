# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

RSpec.describe Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:issue) { decision_review_updated.decision_review_issues_removed.first }
  let(:index) { 1 }

  before do
    message_payload["decision_review_issues_removed"].push(
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "NO_CHANGES"
      )
    )

    message_payload["decision_review_issues_removed"].push(
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "",
        "reason_for_contention_action" => ""
      )
    )
  end

  describe "#build_issues" do
    context "when successful" do
      it "creates removed_issues successfully" do
        expect(subject.build_issues.first).to be_an_instance_of(DecisionReviewUpdated::RequestIssue)
      end
    end
  end

  describe "#build_request_issue" do
    before do
      allow(Builders::DecisionReviewUpdated::RequestIssueBuilder).to receive(:build).and_return(true)
    end

    context "when successful" do
      it "does not raise an error" do
        expect(subject.build_request_issue(issue, index)).to eq(true)
      end
    end

    context "when unsuccessful" do
      before do
        allow(Builders::DecisionReviewUpdated::RequestIssueBuilder).to receive(:build).and_raise(StandardError)
      end

      it "raises an error" do
        expect do
          subject.build_request_issue(issue, index)
        end.to raise_error(AppealsConsumer::Error::RequestIssueBuildError)
      end
    end
  end

  describe "#removed_issues" do
    context "when decision review removed issues are present" do
      it "returns correct number of removed_issues" do
        expect(subject.removed_issues.count).to eq(1)
      end

      it "has the correct issues" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq(subject.send(:removed))
          expect(issue.contention_action).to eq(subject.send(:contention_deleted))
        end
      end

      it "does not have incorrect issues" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq("NEW_ELIGIBLE_ISSUE")
          expect(issue.reason_for_contention_action).not_to eq("NO_CHANGES")
          expect(issue.reason_for_contention_action).not_to eq("PRIOR_DECISION_TEXT_CHANGED")
          expect(issue.reason_for_contention_action).not_to eq("ELIGIBLE_TO_INELIGIBLE")
          expect(issue.reason_for_contention_action).not_to eq("INELIGIBLE_REASON_CHANGED")
          expect(issue.reason_for_contention_action).not_to eq("INELIGIBLE_TO_ELIGIBLE")
          expect(issue.reason_for_contention_action).not_to eq("WITHDRAWN_SELECTED")
          expect(issue.contention_action).not_to eq("ADD_CONTENTION")
          expect(issue.contention_action).not_to eq("NONE")
          expect(issue.contention_action).not_to eq("UPDATE_CONTENTION")
        end
      end
    end

    context "when decision review removed issues are empty" do
      before do
        decision_review_updated.decision_review_issues_removed = []
      end

      it "returns an empty array" do
        expect(subject.removed_issues).to eq([])
      end
    end
  end
end
