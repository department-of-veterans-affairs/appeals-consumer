# frozen_string_literal: true

require "shared_context/decision_review_completed_context"

describe Transformers::DecisionReviewCompleted do
  subject(:decision_review_completed) { described_class.new(event_id, message_payload) }

  include_context "decision_review_completed_context"

  let(:event_id) { 96 }

  describe "#initialize" do
    context "when Transformers::DecisionReviewCompleted and DecisionReviewIssue portions of payload have valid "\
    "attributes and data types" do
      it "initializes a Transformers::DecisionReviewCreated object" do
        expect(subject.claim_id).to be_an_instance_of(Integer)
        expect(subject.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
        expect(subject.veteran_participant_id).to be_an_instance_of(String)
        expect(subject.claimant_participant_id).to be_an_instance_of(String)
        expect(subject.remand_created).to be_an_instance_of(NilClass)
        expect(subject.ep_code_category).to eq("NON_RATING")
        expect(subject.claim_lifecycle_status).to eq("CLR")
        expect(subject.actor_username).to eq("BVADWISE101")
        expect(subject.actor_application).to eq("PASYSACCTCREATE")
        expect(subject.completion_time).to be_an_instance_of(String)
        expect(subject.decision_review_issues_completed.size).to eq(2)
      end

      it "initializes DecisionReviewIssue objects for every obj in issues_array" do
        subject.decision_review_issues_completed.each do |issue|
          expect(issue).to be_an_instance_of(DecisionReviewIssueCompleted)

          # this additional logic of checking the issues by contention_id enables us to not rely on the index each
          # DecisionReviewIssue is stored at since the index order could change when Github Actions runs
          case issue.contention_id
          when 345_456_567
            expect(issue.contention_id).to eq(345_456_567)
            expect(issue.decision_review_issue_id).to eq(1)
            expect(issue.remand_claim_id).to eq(1)
            expect(issue.remand_contention_id).to eq(1)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(12)
            expect(issue.prior_caseflow_decision_issue_id).to eq(nil)
            expect(issue.prior_decision_rating_sn).to eq(nil)
            expect(issue.prior_decision_text).to eq("DIC: Service connection for tetnus denied")
            expect(issue.prior_decision_type).to eq("DIC")
            expect(issue.prior_decision_source).to eq(nil)
            expect(issue.prior_decision_notification_date).to eq("2023-08-01")
            expect(issue.legacy_appeal_issue_id).to eq(nil)
            expect(issue.prior_decision_rating_profile_date).to eq(nil)
            expect(issue.soc_opt_in).to eq(nil)
            expect(issue.legacy_appeal_id).to eq(nil)
          when 987_876_765
            expect(issue.contention_id).to eq(987_876_765)
            expect(issue.decision_review_issue_id).to eq(1)
            expect(issue.remand_claim_id).to eq(1)
            expect(issue.remand_contention_id).to eq(1)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(12)
            expect(issue.prior_caseflow_decision_issue_id).to eq(nil)
            expect(issue.prior_decision_rating_sn).to eq(nil)
            expect(issue.prior_decision_text).to eq("DIC: Service connection for tetnus denied")
            expect(issue.prior_decision_type).to eq("DIC")
            expect(issue.prior_decision_source).to eq(nil)
            expect(issue.prior_decision_notification_date).to eq("2023-08-01")
            expect(issue.legacy_appeal_issue_id).to eq(nil)
            expect(issue.prior_decision_rating_profile_date).to eq(nil)
            expect(issue.soc_opt_in).to eq(nil)
            expect(issue.legacy_appeal_id).to eq(nil)
          end
        end
      end

      it "does not raise ArgumentError" do
        expect { subject }.not_to raise_error
      end
    end

    context "when Transformers::DecisionReviewCreated portion of message_payload is invalid" do
      context "because payload is nil" do
        let(:nil_message_payload) { build(:decision_review_created, :nil) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "Transformers::DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { nil_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:empty_message_payload) { build(:decision_review_created, :empty) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "Transformers::DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { empty_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "when there are unexpected attribute name(s)" do
        let(:message_payload_with_invalid_attribute_name) { build(:decision_review_created, :invalid_attribute_name) }
        let(:message_payload_with_multiple_invalid_names) do
          build(:decision_review_created, :multiple_invalid_attribute_names)
        end

        context "when there is a single unexpected attribute name" do
          it "logs the unknown attribute name" do
            message = "Transformers::DecisionReviewCreated: Unknown attributes - invalid_attribute"
            expect(Rails.logger).to receive(:info).with(message)
            message_payload_with_invalid_attribute_name
          end
        end

        context "when there are multiple unexpected attribute names" do
          it "logs all the unknown attribute names" do
            message = "Transformers::DecisionReviewCreated: Unknown attributes - invalid_attribute, "\
            "second_invalid_attribute"
            expect(Rails.logger).to receive(:info).with(message)
            message_payload_with_multiple_invalid_names
          end
        end
      end

      context "because payload has invalid attribute data type(s)" do
        let(:message_payload_with_invalid_data_type) { build(:decision_review_created, :invalid_data_type) }

        it "raises ArgumentError with message: class_name: name must be one of the allowed types, got class." do
          error_message = "Transformers::DecisionReviewCreated: claim_id must be one of the allowed types "\
          "- [Integer], got String"
          expect { message_payload_with_invalid_data_type }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues_created is an empty array" do
        let(:message_payload_without_decision_review_issues_created) do
          build(:decision_review_created, :without_decision_review_issues_created)
        end

        it "raises ArgumentError with message: Transformers::DecisionReviewCreated: Message payload must include at "\
        "least one decision review issue" do
          error_message = "Transformers::DecisionReviewCreated: Message payload must include at least one decision "\
          "review issue created"
          expect { message_payload_without_decision_review_issues_created }.to raise_error(ArgumentError, error_message)
        end
      end
    end

    context "when DecisionReviewIssue portion of message_payload is invalid" do
      context "because payload is nil" do
        let(:message_payload_with_nil_issue) do
          build(:decision_review_created, :with_nil_decision_review_issue_created)
        end

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssueCreated: Message payload cannot be empty or nil"
          expect { message_payload_with_nil_issue }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:message_payload_with_empty_issue) do
          build(:decision_review_created, :with_empty_decision_review_issue_created)
        end

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssueCreated: Message payload cannot be empty or nil"
          expect { message_payload_with_empty_issue }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute name(s)" do
        let(:message_payload_with_invalid_issue_attr_name) do
          build(:decision_review_created, :with_invalid_decision_review_issue_created_attribute_name)
        end
        let(:message_payload_with_multiple_invalid_issue_attr_names) do
          build(:decision_review_created, :with_multiple_invalid_decision_review_issue_created_attribute_names)
        end

        context "when there is a single unexpected attribute name" do
          it "logs the unknown attribute name" do
            message = "DecisionReviewIssueCreated: Unknown attributes - invalid_attribute"
            expect(Rails.logger).to receive(:info).with(message)
            message_payload_with_invalid_issue_attr_name
          end
        end

        context "when there are multiple unexpected attribute names" do
          it "logs all the unknown attribute names" do
            message = "DecisionReviewIssueCreated: Unknown attributes - invalid_attribute, "\
            "second_invalid_attribute"
            expect(Rails.logger).to receive(:info).with(message)
            message_payload_with_multiple_invalid_issue_attr_names
          end
        end
      end

      context "because payload has invalid attribute data type(s)" do
        let(:message_payload_with_invalid_issue_data_type) do
          build(:decision_review_created, :with_invalid_decision_review_issue_created_data_type)
        end

        it "raises ArgumentError with message: class_name: name must be one of the allowed types -, got class." do
          error_message = "DecisionReviewIssueCreated: decision_review_issue_id must be one of the allowed types -" \
           " [Integer], got String"
          expect { message_payload_with_invalid_issue_data_type }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
