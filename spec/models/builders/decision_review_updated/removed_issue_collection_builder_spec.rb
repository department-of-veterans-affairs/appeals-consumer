# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

RSpec.describe Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:issue) { decision_review_updated.decision_review_issues_removed.first }
  let(:index) { 1 }

  describe "#build_issues" do
    context "when successful" do
      it "creates DecisionReviewUpdated::RequestIssue successfully" do
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
    before do
      # Adding issues with combos of reason_for_contention_action & contention_action that should not be possible
      # to all issue attribute categories (ie. decision_review_issues_created, decision_review_issues_removed, etc)
      # to prove that this Collection Builder only pulls issues from the decision_review_issues_removed attribute
      message_payload["decision_review_issues_created"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:removed)
        )
      )

      message_payload["decision_review_issues_withdrawn"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:removed)
        )
      )

      message_payload["decision_review_issues_updated"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:removed)
        )
      )

      message_payload["decision_review_issues_not_changed"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:removed)
        )
      )
    end

    context "when decision review removed issues are present" do
      it "returns correct number of removed_issues" do
        expect(subject.removed_issues.count).to eq(1)
      end

      it "only returns issues with a reason_for_contention_action of 'REMOVED_SELECTED'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq(subject.send(:removed))
        end
      end

      it "only returns issues with a contention_action of 'DELETE_CONTENTION'" do
        subject.removed_issues.each do |issue|
          expect(issue.contention_action).to eq(subject.send(:contention_deleted))
        end
      end

      it "only returns issues from within the decision_review_issues_removed attribute" do
        subject.removed_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_removed).to include(issue)
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'ELIGIBLE_TO_INELIGIBLE'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:eligible_to_ineligible))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_REASON_CHANGED'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_reason_changed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'WITHDRAWN_SELECTED'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:withdrawn))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_TO_ELIGIBLE'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_to_eligible))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'PRIOR_DECISION_TEXT_CHANGED'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:text_changed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NEW_ELIGIBLE_ISSUE'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:issue_added))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NO_CHANGES'" do
        subject.removed_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:no_changes))
        end
      end

      it "does NOT return issues with a contention_action of 'ADD_CONTENTION'" do
        subject.removed_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_added))
        end
      end

      it "does NOT return issues with a contention_action of 'NONE'" do
        subject.removed_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:no_contention_action))
        end
      end

      it "does NOT return issues with a contention_action of 'UPDATE_CONTENTION'" do
        subject.removed_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_updated))
        end
      end

      it "does NOT return any issues from the decision_review_issues_created attribute" do
        subject.removed_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_withdrawn attribute" do
        subject.removed_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_updated attribute" do
        subject.removed_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_not_changed attribute" do
        subject.removed_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
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
