# frozen_string_literal: true

require "timecop"

describe Transformers::DecisionReviewCreated do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  subject { build(:decision_review_created, event_id: 13) }

  describe "#initialize" do
    context "when Transformers::DecisionReviewCreated and DecisionReviewIssue portions of payload have valid "\
    "attributes and data types" do
      it "initializes a Transformers::DecisionReviewCreated object" do
        expect(subject.claim_id).to be_an_instance_of(Integer)
        expect(subject.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
        expect(subject.veteran_first_name).to eq("John")
        expect(subject.veteran_last_name).to eq("Smith")
        expect(subject.veteran_participant_id).to be_an_instance_of(String)
        expect(subject.file_number).to be_an_instance_of(String)
        expect(subject.claimant_participant_id).to be_an_instance_of(String)
        expect(subject.ep_code).to eq("030HLRNR")
        expect(subject.ep_code_category).to eq("NON_RATING")
        expect(subject.claim_received_date).to eq("2023-08-25")
        expect(subject.claim_lifecycle_status).to eq("Ready to Work")
        expect(subject.payee_code).to eq("00")
        expect(subject.modifier).to eq("01")
        expect(subject.limited_poa_code).to eq nil
        expect(subject.originated_from_vacols_issue).to eq(false)
        expect(subject.informal_conference_requested).to eq(false)
        expect(subject.informal_conference_tracked_item_id).to eq("1")
        expect(subject.same_station_review_requested).to eq(false)
        expect(subject.intake_creation_time).to be_an_instance_of(String)
        expect(subject.claim_creation_time).to be_an_instance_of(String)
        expect(subject.actor_username).to eq("BVADWISE101")
        expect(subject.actor_station).to eq("101")
        expect(subject.actor_application).to eq("PASYSACCTCREATE")
        expect(subject.decision_review_issues_created.size).to eq(2)
        expect(subject.event_id).to eq(13)
      end

      it "initializes DecisionReviewIssue objects for every obj in issues_array" do
        subject.decision_review_issues_created.each do |issue|
          expect(issue).to be_an_instance_of(DecisionReviewIssueCreated)

          # this additional logic of checking the issues by contention_id enables us to not rely on the index each
          # DecisionReviewIssue is stored at since the index order could change when Github Actions runs
          case issue.contention_id
          when 123_456_789
            expect(issue.contention_id).to eq(123_456_789)
            expect(issue.prior_caseflow_decision_issue_id).to eq(nil)
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(12)
            expect(issue.prior_decision_award_event_id).to eq(17_946)
            expect(issue.prior_decision_text).to eq("DIC: Service connection for tetnus denied")
            expect(issue.prior_decision_type).to eq("DIC")
            expect(issue.prior_decision_notification_date).to eq("2023-08-01")
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_sn).to eq(nil)
            expect(issue.prior_decision_rating_percentage).to eq(nil)
            expect(issue.prior_decision_rating_profile_date).to eq(nil)
            expect(issue.eligible).to eq(true)
            expect(issue.eligibility_result).to eq("ELIGIBLE")
            expect(issue.time_override).to eq(nil)
            expect(issue.time_override_reason).to eq(nil)
            expect(issue.contested).to eq(nil)
            expect(issue.soc_opt_in).to eq(nil)
            expect(issue.legacy_appeal_id).to eq(nil)
            expect(issue.legacy_appeal_issue_id).to eq(nil)
            expect(issue.prior_decision_source).to eq(nil)
          when 123_456_790
            expect(issue.contention_id).to eq(123_456_790)
            expect(issue.prior_caseflow_decision_issue_id).to eq(nil)
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(13)
            expect(issue.prior_decision_award_event_id).to eq(17_946)
            expect(issue.prior_decision_text).to eq("Basic Eligibility: Service connection for ear infection denied")
            expect(issue.prior_decision_type).to eq("Basic Eligibility")
            expect(issue.prior_decision_notification_date).to eq("2023-08-01")
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_sn).to eq(nil)
            expect(issue.prior_decision_rating_percentage).to eq(nil)
            expect(issue.prior_decision_rating_profile_date).to eq(nil)
            expect(issue.eligible).to eq(true)
            expect(issue.eligibility_result).to eq("ELIGIBLE")
            expect(issue.time_override).to eq(nil)
            expect(issue.time_override_reason).to eq(nil)
            expect(issue.contested).to eq(nil)
            expect(issue.soc_opt_in).to eq(nil)
            expect(issue.legacy_appeal_id).to eq(nil)
            expect(issue.legacy_appeal_issue_id).to eq(nil)
            expect(issue.prior_decision_source).to eq(nil)
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
