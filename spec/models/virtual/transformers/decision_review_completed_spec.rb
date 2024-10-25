# frozen_string_literal: true

require "shared_context/decision_review_completed_context"

describe Transformers::DecisionReviewCompleted do
  subject(:decision_review_completed) { described_class.new(event_id, message_payload) }

  include_context "decision_review_completed_context"

  let(:event_id) { 96 }
  let(:drc_class) { decision_review_completed.class }

  describe "#initialize" do
    context "when Transformers::DecisionReviewCompleted, DecisionReviewIssueCompleted, and Decision" \
    " portions of payload have valid attributes and data types" do
      it "initializes a Transformers::DecisionReviewCompleted object" do
        expect(subject.claim_id).to eq(message_payload["claim_id"])
        expect(subject.decision_review_type).to eq(message_payload["decision_review_type"])
        expect(subject.veteran_participant_id).to eq(message_payload["veteran_participant_id"])
        expect(subject.claimant_participant_id).to eq(message_payload["claimant_participant_id"])
        expect(subject.remand_created).to eq(message_payload["remand_created"])
        expect(subject.ep_code_category).to eq(message_payload["ep_code_category"])
        expect(subject.claim_lifecycle_status).to eq(message_payload["claim_lifecycle_status"])
        expect(subject.actor_username).to eq(message_payload["actor_username"])
        expect(subject.actor_application).to eq(message_payload["actor_application"])
        expect(subject.completion_time).to eq(message_payload["completion_time"])
        expect(subject.decision_review_issues_completed.size)
          .to eq(message_payload["decision_review_issues_completed"].count)
      end

      it "initializes a DecisionReviewIssueCompleted object for every obj in decision_review_issues_completed array" do
        subject.decision_review_issues_completed.each do |issue|
          expect(issue).to be_an_instance_of(DecisionReviewIssueCompleted)

          # this additional logic of checking the issues by contention_id enables us to not rely on the index each
          # DecisionReviewIssueCompleted is stored at since the index order could change when Github Actions runs
          case issue.contention_id
          when 345_456_567
            expect(issue.contention_id).to eq(completed_decision_review_issue["contention_id"])
            expect(issue.decision_review_issue_id).to eq(completed_decision_review_issue["decision_review_issue_id"])
            expect(issue.remand_claim_id).to eq(completed_decision_review_issue["remand_claim_id"])
            expect(issue.remand_contention_id).to eq(completed_decision_review_issue["remand_contention_id"])
            expect(issue.unidentified).to eq(completed_decision_review_issue["unidentified"])
            expect(issue.prior_rating_decision_id).to eq(completed_decision_review_issue["prior_rating_decision_id"])
            expect(issue.prior_non_rating_decision_id)
              .to eq(completed_decision_review_issue["prior_non_rating_decision_id"])
            expect(issue.prior_caseflow_decision_issue_id)
              .to eq(completed_decision_review_issue["prior_caseflow_decision_issue_id"])
            expect(issue.prior_decision_rating_sn).to eq(completed_decision_review_issue["prior_decision_rating_sn"])
            expect(issue.prior_decision_text).to eq(completed_decision_review_issue["prior_decision_text"])
            expect(issue.prior_decision_type).to eq(completed_decision_review_issue["prior_decision_type"])
            expect(issue.prior_decision_source).to eq(completed_decision_review_issue["prior_decision_source"])
            expect(issue.prior_decision_notification_date)
              .to eq(completed_decision_review_issue["prior_decision_notification_date"])
            expect(issue.legacy_appeal_issue_id).to eq(completed_decision_review_issue["legacy_appeal_issue_id"])
            expect(issue.prior_decision_rating_profile_date)
              .to eq(completed_decision_review_issue["prior_decision_rating_profile_date"])
            expect(issue.soc_opt_in).to eq(completed_decision_review_issue["soc_opt_in"])
            expect(issue.legacy_appeal_id).to eq(completed_decision_review_issue["legacy_appeal_id"])
          when 987_876_765
            expect(issue.contention_id).to eq(canceled_decision_review_issue["contention_id"])
            expect(issue.decision_review_issue_id).to eq(canceled_decision_review_issue["decision_review_issue_id"])
            expect(issue.remand_claim_id).to eq(canceled_decision_review_issue["remand_claim_id"])
            expect(issue.remand_contention_id).to eq(canceled_decision_review_issue["remand_contention_id"])
            expect(issue.unidentified).to eq(canceled_decision_review_issue["unidentified"])
            expect(issue.prior_rating_decision_id).to eq(canceled_decision_review_issue["prior_rating_decision_id"])
            expect(issue.prior_non_rating_decision_id)
              .to eq(canceled_decision_review_issue["prior_non_rating_decision_id"])
            expect(issue.prior_caseflow_decision_issue_id)
              .to eq(canceled_decision_review_issue["prior_caseflow_decision_issue_id"])
            expect(issue.prior_decision_rating_sn).to eq(canceled_decision_review_issue["prior_decision_rating_sn"])
            expect(issue.prior_decision_text).to eq(canceled_decision_review_issue["prior_decision_text"])
            expect(issue.prior_decision_type).to eq(canceled_decision_review_issue["prior_decision_type"])
            expect(issue.prior_decision_source).to eq(canceled_decision_review_issue["prior_decision_source"])
            expect(issue.prior_decision_notification_date)
              .to eq(canceled_decision_review_issue["prior_decision_notification_date"])
            expect(issue.legacy_appeal_issue_id).to eq(canceled_decision_review_issue["legacy_appeal_issue_id"])
            expect(issue.prior_decision_rating_profile_date)
              .to eq(canceled_decision_review_issue["prior_decision_rating_profile_date"])
            expect(issue.soc_opt_in).to eq(canceled_decision_review_issue["soc_opt_in"])
            expect(issue.legacy_appeal_id).to eq(canceled_decision_review_issue["legacy_appeal_id"])
          end
        end
      end

      it "initializes a Decision object for every DecisionReviewIssueCompleted"\
      " with a non-nil decision field" do
        subject.decision_review_issues_completed.each do |issue|
          decision = issue.decision

          case issue.contention_id
          when 345_456_567
            expect(decision).to be_an_instance_of(Decision)
            expect(decision.contention_id).to eq(completed_decision["contention_id"])
            expect(decision.disposition).to eq(completed_decision["disposition"])
            expect(decision.dta_error_explanation).to eq(completed_decision["dta_error_explanation"])
            expect(decision.decision_source).to eq(completed_decision["decision_source"])
            expect(decision.category).to eq(completed_decision["category"])
            expect(decision.decision_id).to eq(completed_decision["decision_id"])
            expect(decision.decision_text).to eq(completed_decision["decision_text"])
            expect(decision.award_event_id).to eq(completed_decision["award_event_id"])
            expect(decision.rating_profile_date).to eq(completed_decision["rating_profile_date"])
            expect(decision.decision_recorded_time).to eq(completed_decision["decision_recorded_time"])
            expect(decision.decision_finalized_time).to eq(completed_decision["decision_finalized_time"])
          when 987_876_765
            expect(decision).not_to be_an_instance_of(Decision)
            expect(decision).to be_nil
          end
        end
      end

      it "does not raise ArgumentError" do
        expect { subject }.not_to raise_error
      end
    end

    context "when Transformers::DecisionReviewCompleted portion of message_payload is invalid" do
      context "because payload is nil" do
        let(:nil_message_payload) { described_class.new(nil, nil) }

        it "raises ArgumentError with message" do
          error_message = "#{drc_class}: Message payload cannot be empty or nil"
          expect { nil_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:empty_message_payload) { described_class.new(nil, {}) }

        it "raises ArgumentError with message" do
          error_message = "#{drc_class}: Message payload cannot be empty or nil"
          expect { empty_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute data type(s)" do
        let(:message_payload_with_invalid_data_type) do
          message_payload.merge(
            "claim_id" => "87213"
          )
        end

        it "raises ArgumentError with message" do
          error_message = "#{drc_class}: claim_id must be one of the allowed types - [Integer], got String"
          expect { described_class.new(event_id, message_payload_with_invalid_data_type) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has unexpected attribute name(s)" do
        let(:message_payload_with_multiple_invalid_attribute_names) do
          message_payload.merge(
            "invalid_attr" => "key",
            "second_invalid_attr" => 123
          )
        end
        it "logs all the unknown attribute names" do
          message = "#{drc_class}: Unknown attributes - invalid_attr, second_invalid_attr"
          expect(Rails.logger).to receive(:info).with(message)
          described_class.new(event_id, message_payload_with_multiple_invalid_attribute_names)
        end
      end
    end

    context "when DecisionReviewIssueCompleted portion of message_payload is invalid" do
      context "because decision_review_issues_completed is an empty array" do
        let(:message_payload_with_empty_decision_review_issues_completed) do
          message_payload.merge(
            "decision_review_issues_completed" => []
          )
        end

        it "raises ArgumentError with message" do
          error_message = "#{drc_class}: Message payload must include at least one decision review issue completed"
          expect { described_class.new(event_id, message_payload_with_empty_decision_review_issues_completed) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues_completed hash is empty" do
        let(:message_payload_with_empty_issue) do
          message_payload.merge(
            "decision_review_issues_completed" => [{}]
          )
        end

        it "raises ArgumentError with message" do
          error_message = "DecisionReviewIssueCompleted: Message payload cannot be empty or nil"
          expect { described_class.new(event_id, message_payload_with_empty_issue) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues_completed has invalid data type(s)" do
        let(:decision_review_issue_completed_with_invalid_data_type) do
          completed_decision_review_issue.merge(
            "contention_id" => "string data type"
          )
        end
        let(:message_payload_with_invalid_issue_data_type) do
          message_payload.merge(
            "decision_review_issues_completed" => [decision_review_issue_completed_with_invalid_data_type]
          )
        end

        it "raises ArgumentError with message" do
          error_message = "DecisionReviewIssueCompleted: contention_id must be one of the allowed types"\
          " - [Integer, NilClass], got String"
          expect { described_class.new(event_id, message_payload_with_invalid_issue_data_type) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues_completed has unexpected attribute name(s)" do
        let(:decision_review_issue_completed_with_invalid_attr_names) do
          completed_decision_review_issue.merge(
            "invalid_attr" => "string",
            "second_invalid_attr" => 1234
          )
        end
        let(:message_payload_with_invalid_issue_attr_names) do
          message_payload.merge(
            "decision_review_issues_completed" => [decision_review_issue_completed_with_invalid_attr_names]
          )
        end

        it "logs all the unknown attribute names" do
          message = "DecisionReviewIssueCompleted: Unknown attributes - invalid_attr, "\
          "second_invalid_attr"
          expect(Rails.logger).to receive(:info).with(message)
          described_class.new(event_id, message_payload_with_invalid_issue_attr_names)
        end
      end
    end

    context "when Decision portion of message_payload is invalid" do
      context "because decision is an empty hash" do
        let(:decision_review_issue_completed_with_nil_decision) do
          completed_decision_review_issue.merge(
            "decision" => {}
          )
        end
        let(:message_payload_with_nil_decision) do
          message_payload.merge(
            "decision_review_issues_completed" => [decision_review_issue_completed_with_nil_decision]
          )
        end

        it "raises ArgumentError with message" do
          error_message = "Decision: Message payload cannot be empty"
          expect { described_class.new(event_id, message_payload_with_nil_decision) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision has invalid data type(s)" do
        let(:decision_review_issue_completed_with_invalid_attr_types) do
          completed_decision_review_issue.merge(
            "decision" => decision_with_invalid_attr_types
          )
        end
        let(:message_payload_with_invalid_attr_types) do
          message_payload.merge(
            "decision_review_issues_completed" => [decision_review_issue_completed_with_invalid_attr_types]
          )
        end

        it "raises ArgumentError with message" do
          error_message = "Decision: contention_id must be one of the allowed types - [Integer], got String"
          expect { described_class.new(event_id, message_payload_with_invalid_attr_types) }
            .to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision has unexpected attribute name(s)" do
        let(:decision_review_issue_completed_with_invalid_attr_names) do
          completed_decision_review_issue.merge(
            "decision" => decision_with_invalid_attr_names
          )
        end
        let(:message_payload_with_invalid_attr_names) do
          message_payload.merge(
            "decision_review_issues_completed" => [decision_review_issue_completed_with_invalid_attr_names]
          )
        end

        it "logs all the unknown attribute names" do
          message = "Decision: Unknown attributes - invalid_attr, second_invalid_attr"
          expect(Rails.logger).to receive(:info).with(message)
          described_class.new(event_id, message_payload_with_invalid_attr_names)
        end
      end
    end
  end
end
