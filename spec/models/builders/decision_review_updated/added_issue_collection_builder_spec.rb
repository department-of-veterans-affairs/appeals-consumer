# frozen_string_literal: true

require "shared_context/decision_review_updated_context"
require "shared_examples/decision_review_updated/request_issue_collection_builders"

RSpec.describe Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder, type: :model do
  subject { described_class.new(decision_review_updated) }

  include_context "decision_review_updated_context"
  include_examples "request_issue_collection_builders"

  let(:decision_review_updated) { build(:decision_review_updated, message_payload: message_payload) }
  let(:builder) { described_class.new(decision_review_updated) }
  let(:issue) { decision_review_updated.decision_review_issues_created.first }
  let(:index) { 1 }

  describe "#newly_added_eligible_issues" do
    context "when decision review created issues are present" do
      before do
        # Adding issues with combos of reason_for_contention_action & contention_action that should not be possible
        # to all issue attribute categories (ie. decision_review_issues_created, decision_review_issues_removed, etc)
        # to prove that this Collection Builder only pulls issues from the decision_review_issues_created attribute
        message_payload["decision_review_issues_updated"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:contention_added),
            "reason_for_contention_action" => subject.send(:issue_added)
          )
        )

        message_payload["decision_review_issues_removed"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:contention_added),
            "reason_for_contention_action" => subject.send(:issue_added)
          )
        )

        message_payload["decision_review_issues_withdrawn"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:contention_added),
            "reason_for_contention_action" => subject.send(:issue_added)
          )
        )

        message_payload["decision_review_issues_not_changed"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:contention_added),
            "reason_for_contention_action" => subject.send(:issue_added)
          )
        )
      end

      context "when decision review created issues are present" do
        it "returns correct number of newly_added_eligible_issues" do
          expect(subject.newly_added_eligible_issues.count).to eq(1)
        end

        it "only returns issues with a reason_for_contention_action of 'NEW_ELIGIBLE_ISSUE'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).to eq(subject.send(:issue_added))
          end
        end

        it "only returns issues with a contention_action of 'ADD_CONTENTION'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.contention_action).to eq(subject.send(:contention_added))
          end
        end

        it "only returns issues from within the decision_review_issues_created attribute" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_created).to include(issue)
            expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'ELIGIBLE_TO_INELIGIBLE'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:eligible_to_ineligible))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_REASON_CHANGED'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_reason_changed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'REMOVED_SELECTED'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:removed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'WITHDRAWN_SELECTED'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:withdrawn))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'PRIOR_DECISION_TEXT_CHANGED'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:text_changed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_TO_ELIGIBLE'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_to_eligible))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'NO_CHANGES'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:no_changes))
          end
        end

        it "does NOT return issues with a contention_action of 'DELETE_CONTENTION'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:contention_deleted))
          end
        end

        it "does NOT return issues with a contention_action of 'NONE'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:no_contention_action))
          end
        end

        it "does NOT return issues with a contention_action of 'UPDATE_CONTENTION'" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:contention_updated))
          end
        end

        it "does NOT return any issues from the decision_review_issues_updated attribute" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_removed attribute" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_withdrawn attribute" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_not_changed attribute" do
          subject.newly_added_eligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
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

  describe "#newly_added_ineligible_issues" do
    context "when decision review created issues are present" do
      before do
        # Adding issues with combos of reason_for_contention_action & contention_action that should not be possible
        # to all issue attribute categories (ie. decision_review_issues_created, decision_review_issues_removed, etc)
        # to prove that this Collection Builder only pulls issues from the decision_review_issues_created attribute
        message_payload["decision_review_issues_updated"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:no_contention_action),
            "reason_for_contention_action" => subject.send(:no_changes)
          )
        )

        message_payload["decision_review_issues_removed"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:no_contention_action),
            "reason_for_contention_action" => subject.send(:no_changes)
          )
        )

        message_payload["decision_review_issues_withdrawn"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:no_contention_action),
            "reason_for_contention_action" => subject.send(:no_changes)
          )
        )

        message_payload["decision_review_issues_not_changed"].push(
          base_decision_review_issue.merge(
            "contention_id" => 123_456,
            "contention_action" => subject.send(:no_contention_action),
            "reason_for_contention_action" => subject.send(:no_changes)
          )
        )
      end

      context "when decision review created issues are present" do
        it "returns correct number of newly_added_ineligible_issues" do
          expect(subject.newly_added_ineligible_issues.count).to eq(1)
        end

        it "only returns issues with a reason_for_contention_action of 'NO_CHANGES'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).to eq(subject.send(:no_changes))
          end
        end

        it "only returns issues with a contention_action of 'NONE'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.contention_action).to eq(subject.send(:no_contention_action))
          end
        end

        it "only returns issues from within the decision_review_issues_created attribute" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_created).to include(issue)
            expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
            expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'ELIGIBLE_TO_INELIGIBLE'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:eligible_to_ineligible))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_REASON_CHANGED'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_reason_changed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'REMOVED_SELECTED'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:removed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'WITHDRAWN_SELECTED'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:withdrawn))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'PRIOR_DECISION_TEXT_CHANGED'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:text_changed))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'INELIGIBLE_TO_ELIGIBLE'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:ineligible_to_eligible))
          end
        end

        it "does NOT return issues with a reason_for_contention_action of 'NEW_ELIGIBLE_ISSUE'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.reason_for_contention_action).not_to eq(subject.send(:issue_added))
          end
        end

        it "does NOT return issues with a contention_action of 'DELETE_CONTENTION'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:contention_deleted))
          end
        end

        it "does NOT return issues with a contention_action of 'ADD_CONTENTION'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:contention_added))
          end
        end

        it "does NOT return issues with a contention_action of 'UPDATE_CONTENTION'" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(issue.contention_action).not_to eq(subject.send(:contention_updated))
          end
        end

        it "does NOT return any issues from the decision_review_issues_updated attribute" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_updated).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_removed attribute" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_removed).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_withdrawn attribute" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_withdrawn).not_to include(issue)
          end
        end

        it "does NOT return any issues from the decision_review_issues_not_changed attribute" do
          subject.newly_added_ineligible_issues.each do |issue|
            expect(decision_review_updated.decision_review_issues_not_changed).not_to include(issue)
          end
        end
      end
    end

    context "when decision review created issues are empty" do
      before do
        decision_review_updated.decision_review_issues_created = []
      end

      it "returns an empty array" do
        expect(subject.newly_added_ineligible_issues).to eq([])
      end
    end
  end
end
