# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe Builders::DecisionReviewUpdated::IneligibleToEligibleIssueCollectionBuilder do
  subject { described_class.new(decision_review_updated) }
  include_context "decision_review_updated_context"
  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:issue) { decision_review_updated.decision_review_issues_created.first }
  let(:index) { 1 }

  describe "#build_issues" do
    context "when successful" do
      it "creates added_issues successfully" do
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

  describe "#ineligible_to_eligible_issues" do
    context "when decision review updated issues are present" do
      it "returns correct numbder of ineligible_to_eligible_issues" do
        expect(subject.ineligible_to_eligible_issues.count).to eq(1)
      end

      it "has the correct issues" do
        subject.ineligible_to_eligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("INELIGIBLE_TO_ELIGIBLE")
          expect(issue.contention_action).to eq("ADD_CONTENTION")
          expect(issue.contention_action).not_to eq("ELIGIBLE_TO_INELIGIBLE")
          expect(issue.reason_for_contention_action).not_to eq("DELETE_CONTENTION")
        end
      end
    end

    context "when decision review updated issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array" do
        expect(subject.ineligible_to_eligible_issues).to eq([])
      end
    end
  end
end
