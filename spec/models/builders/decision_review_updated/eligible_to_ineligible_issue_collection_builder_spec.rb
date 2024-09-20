# frozen_string_literal: true

require "shared_context/decision_review_updated_context"
require "shared_examples/decision_review_updated/request_issue_collection_builders"

RSpec.describe Builders::DecisionReviewUpdated::EligibleToIneligibleIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"
  include_examples "request_issue_collection_builders"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:builder) { described_class.new(decision_review_updated) }
  let(:issue) do
    decision_review_updated.decision_review_issues_updated.find do |issue|
      issue.contention_action == subject.send(:contention_deleted) &&
        issue.reason_for_contention_action == subject.send(:eligible_to_ineligible)
    end
  end
  let(:index) { 1 }

  describe "#eligible_to_ineligible_issues" do
    before do
      # Adding issues with combos of reason_for_contention_action & contention_action that should not be possible
      # to all issue attribute categories (ie. decision_review_issues_created, decision_review_issues_removed, etc)
      # to prove that this Collection Builder only pulls issues from the decision_review_issues_updated attribute
      message_payload["decision_review_issues_created"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:eligible_to_ineligible)
        )
      )

      message_payload["decision_review_issues_removed"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:eligible_to_ineligible)
        )
      )

      message_payload["decision_review_issues_withdrawn"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:eligible_to_ineligible)
        )
      )

      message_payload["decision_review_issues_not_changed"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:contention_deleted),
          "reason_for_contention_action" => subject.send(:eligible_to_ineligible)
        )
      )
    end
    context "when decision review updated issues are present" do
      it "returns correct numbder of eligible_to_ineligible" do
        expect(subject.eligible_to_ineligible_issues.count).to eq(1)
      end

      it "only returns issues with a reason_for_contention_action of 'ELIGIBLE_TO_INELIGIBLE'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq(subject.send(:eligible_to_ineligible))
        end
      end

      it "only returns issues with a contention_action of 'DELETE_CONTENTION'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).to eq(subject.send(:contention_deleted))
        end
      end

      it "only returns issues from within the decision_review_issues_updated attribute" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_updated).to include(issue)
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_TO_ELIGIBLE'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_to_eligible))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_REASON_CHANGED'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_reason_changed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'REMOVED_SELECTED'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:removed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'WITHDRAWN_SELECTED'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:withdrawn))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'PRIOR_DECISION_TEXT_CHANGED'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:text_changed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NEW_ELIGIBLE_ISSUE'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:issue_added))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NO_CHANGES'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:no_changes))
        end
      end

      it "does NOT return issues with a contention_action of 'ADD_CONTENTION'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_added))
        end
      end

      it "does NOT return issues with a contention_action of 'NONE'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:no_contention_action))
        end
      end

      it "does NOT return issues with a contention_action of 'UPDATE_CONTENTION'" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_updated))
        end
      end

      it "does NOT return any issues from the decision_review_issues_created attribute" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_removed attribute" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_withdrawn attribute" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_not_changed attribute" do
        subject.eligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
        end
      end
    end

    context "when decision review updated issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array" do
        expect(subject.eligible_to_ineligible_issues).to eq([])
      end
    end
  end
end
