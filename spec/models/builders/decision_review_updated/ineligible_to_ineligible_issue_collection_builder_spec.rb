# frozen_string_literal: true

require "shared_context/decision_review_updated_context"
require "shared_examples/decision_review_updated/request_issue_collection_builders"

describe Builders::DecisionReviewUpdated::IneligibleToIneligibleIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"
  include_examples "request_issue_collection_builders"

  let(:decision_review_updated) do
    Transformers::DecisionReviewUpdated.new(decision_review_updated_event.id,
                                            decision_review_updated_event.message_payload)
  end
  let(:builder) { described_class.new(decision_review_updated) }
  let(:issue) do
    decision_review_updated.decision_review_issues_updated.find { |issue|
      issue.contention_action == subject.send(:no_contention_action) &&
      issue.reason_for_contention_action == subject.send(:ineligible_reason_changed)
    }
  end
  let(:index) { 1 }
  let(:decision_review_updated_event) do
    FactoryBot.create(:event, type: "Events::DecisionReviewUpdatedEvent", message_payload: message_payload)
  end

  describe "#ineligible_to_ineligible_issues" do
    before do
      # Adding issues with combos of reason_for_contention_action & contention_action that should not be possible
      # to all issue attribute categories (ie. decision_review_issues_created, decision_review_issues_removed, etc)
      # to prove that this Collection Builder only pulls issues from the decision_review_issues_updated attribute
      message_payload["decision_review_issues_created"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:no_contention_action),
          "reason_for_contention_action" => subject.send(:ineligible_reason_changed)
        )
      )

      message_payload["decision_review_issues_removed"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:no_contention_action),
          "reason_for_contention_action" => subject.send(:ineligible_reason_changed)
        )
      )

      message_payload["decision_review_issues_withdrawn"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:no_contention_action),
          "reason_for_contention_action" => subject.send(:ineligible_reason_changed)
        )
      )

      message_payload["decision_review_issues_not_changed"].push(
        base_decision_review_issue.merge(
          "contention_id" => 123_456,
          "contention_action" => subject.send(:no_contention_action),
          "reason_for_contention_action" => subject.send(:ineligible_reason_changed)
        )
      )
    end

    context "when decision review updated issues are present" do
      it "returns correct number of ineligible_to_ineligible_issues" do
        expect(subject.ineligible_to_ineligible_issues.count).to eq(1)
      end

      it "only returns issues with a reason_for_contention_action of 'INELIGIBLE_REASON_CHANGED'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq(subject.send(:ineligible_reason_changed))
        end
      end

      it "only returns issues with a contention_action of 'NONE'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).to eq(subject.send(:no_contention_action))
        end
      end
    end

    context "When decision review updated issues that originated from caseflow" do
      it "builds correct datapoints for an issue that originated from Caseflow" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).to eq(subject.send(:ineligible_reason_changed))
          expect(issue.contention_action).to eq(subject.send(:no_contention_action))
          expect(issue.original_caseflow_request_issue_id).to eq(123_45)
        end
      end

      it "only returns issues from within the decision_review_issues_updated attribute" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_updated).to include(issue)
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'ELIGIBLE_TO_INELIGIBLE'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:eligible_to_ineligible))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_TO_ELIGIBLE'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_to_eligible))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'REMOVED_SELECTED'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:removed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'WITHDRAWN_SELECTED'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:withdrawn))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'PRIOR_DECISION_TEXT_CHANGED'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:text_changed))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NEW_ELIGIBLE_ISSUE'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:issue_added))
        end
      end

      it "does NOT return issues with a reason_for_contention_action of 'NO_CHANGES'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.reason_for_contention_action).not_to eq(subject.send(:no_changes))
        end
      end

      it "does NOT return issues with a contention_action of 'DELETE_CONTENTION'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_deleted))
        end
      end

      it "does NOT return issues with a contention_action of 'ADD_CONTENTION'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_added))
        end
      end

      it "does NOT return issues with a contention_action of 'UPDATE_CONTENTION'" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(issue.contention_action).not_to eq(subject.send(:contention_updated))
        end
      end

      it "does NOT return any issues from the decision_review_issues_created attribute" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_created).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_removed attribute" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_withdrawn attribute" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
        end
      end

      it "does NOT return any issues from the decision_review_issues_not_changed attribute" do
        subject.ineligible_to_ineligible_issues.each do |issue|
          expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
        end
      end
    end

    context "when decision_review_updated_issues are empty" do
      before do
        decision_review_updated.decision_review_issues_updated = []
      end

      it "returns an empty array even if ineligigble_reason_changed and no_contention_action is
      in created, removed, withdrawn, not_changed" do
        expect(subject.ineligible_to_ineligible_issues).to eq([])
      end
    end
  end
end
