# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

RSpec.describe Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:issue) { decision_review_updated.decision_review_issues_updated.first }
  let(:index) { 1 }

  before do
    message_payload["decision_review_issues_updated"].push(
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "UPDATE_CONTENTION",
        "reason_for_contention_action" => "PRIOR_DECISION_TEXT_CHANGED"
      )
    )

    message_payload["decision_review_issues_updated"].push(
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "PRIOR_DECISION_TEXT_CHANGED"
      )
    )

    # This issue does not fulfill requirements for updated issues and
    # should be ignored by UpdatedIssueCollectionBuilder
    message_payload["decision_review_issues_updated"].push(
      base_decision_review_issue.merge(
        "contention_id" => 123_456,
        "contention_action" => "NONE",
        "reason_for_contention_action" => "NO_CHANGES"
      )
    )
  end

  describe "#build_issues" do
    context "when successful" do
      it "creates updated_issues successfully" do
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

  describe "#updated_issues" do
    context "when decision review updated issues are present" do
      it "returns correct number of update_contention_issues" do
        expect(subject.updated_issues.count).to eq(2)
      end

      it "has the correct issues" do
        subject.updated_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("PRIOR_DECISION_TEXT_CHANGED")
          expect(issue.contention_action).to be_in(%w[UPDATE_CONTENTION NONE])
        end
      end
    end

    context "when decision review updated issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array" do
        expect(subject.updated_issues).to eq([])
      end
    end
  end

  describe "#update_contention_issues" do
    context "when decision review updated issues are present" do
      it "returns correct number of update_contention_issues" do
        expect(subject.update_contention_issues.count).to eq(1)
      end

      it "has the correct issues" do
        subject.update_contention_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("PRIOR_DECISION_TEXT_CHANGED")
          expect(issue.contention_action).to eq("UPDATE_CONTENTION")
        end
      end
    end

    context "when decision review updated issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array" do
        expect(subject.update_contention_issues).to eq([])
      end
    end
  end

  describe "#contention_action_none_issues" do
    context "when decision review updated issues are present" do
      it "returns correct number of contention_action_none_issues" do
        expect(subject.contention_action_none_issues.count).to eq(1)
      end

      it "has the correct issues" do
        subject.contention_action_none_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq("PRIOR_DECISION_TEXT_CHANGED")
          expect(issue.contention_action).to eq("NONE")
        end
      end
    end

    context "when decision review updated issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array" do
        expect(subject.contention_action_none_issues).to eq([])
      end
    end
  end
end
