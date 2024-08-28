# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

RSpec.describe Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:issue) { decision_review_updated.decision_review_issues_created.first }
  let(:index) { 1 }

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

  describe "#newly_added_eligible_issues" do
    context "when decision review created issues are present" do
      it "returns newly_added_eligible_issues" do
        expect(subject.newly_added_eligible_issues).to eq(decision_review_updated.decision_review_issues_created)
      end

      it "has the correct issues" do
        subject.newly_added_eligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("NEWLY_ELIGIBLE_ISSUE")
          expect(issue.contention_action).to eq("ADD_CONTENTION")
        end
      end
    end

    context "when decision review created issues are empty" do
      before do
        decision_review_updated.decision_review_issues_created = []
      end

      it "returns an empty array" do
        expect(subject.newly_added_eligible_issues).to eq([])
      end
    end
  end

  describe "#newly_added_inligible_issues" do
    let(:decision_review_issues_created) do
      base_decision_review_issue.merge(
        "decision_review_issue_id" => nil,
        "contention_id" => 123_456,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "No Changes",
        "prior_decision_text" => "An unidentified issue added during the edit"
      )
    end

    context "when decision review created issues are present" do
      it "returns newly_added_eligible_issues" do
        expect(subject.newly_added_ineligible_issues).to eq(decision_review_updated.decision_review_issues_created)
      end

      it "has the correct issues" do
        subject.newly_added_eligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("No Changes")
          expect(issue.contention_action).to eq("NONE")
        end
      end
    end

    context "when decision review created issues are empty" do
      before do
        decision_review_updated.decision_review_issues_created = []
      end

      it "returns an empty array" do
        expect(subject.newly_added_eligible_issues).to eq([])
      end
    end
  end
end
