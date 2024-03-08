# frozen_string_literal: true

require "timecop"
require "./app/models/decision_review_created"

describe DecisionReviewCreated do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  subject { build(:decision_review_created) }

  describe "#initialize" do
    context "when DecisionReviewCreated and DecisionReviewIssue portions of payload have valid attributes and
            data types" do
      it "initializes a DecisionReviewCreated object" do
        expect(subject.claim_id).to eq(1_234_567)
        expect(subject.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
        expect(subject.veteran_first_name).to eq("John")
        expect(subject.veteran_last_name).to eq("Smith")
        expect(subject.veteran_participant_id).to eq("123456789")
        expect(subject.file_number).to eq("123456789")
        expect(subject.claimant_participant_id).to eq("01010101")
        expect(subject.ep_code).to eq("030HLRNR")
        expect(subject.ep_code_category).to eq("non-rating")
        expect(subject.claim_received_date).to eq(1954)
        expect(subject.claim_lifecycle_status).to eq("RW")
        expect(subject.payee_code).to eq("00")
        expect(subject.modifier).to eq("01")
        expect(subject.limited_poa_code).to eq nil
        expect(subject.originated_from_vacols_issue).to eq(false)
        expect(subject.informal_conference_requested).to eq(false)
        expect(subject.informal_conference_tracked_item_id).to eq("1")
        expect(subject.same_station_review_requested).to eq(false)
        expect(subject.intake_creation_time).to be_an_instance_of(Integer)
        expect(subject.claim_creation_time).to be_an_instance_of(Integer)
        expect(subject.created_by_username).to eq("BVADWISE101")
        expect(subject.created_by_station).to eq("101")
        expect(subject.created_by_application).to eq("PASYSACCTCREATE")
        expect(subject.decision_review_issues.size).to eq(2)
      end

      it "initializes DecisionReviewIssue objects for every obj in issues_array" do
        subject.decision_review_issues.each do |issue|
          expect(issue).to be_an_instance_of(DecisionReviewIssue)

          # this additional logic of checking the issues by contention_id enables us to not rely on the index each
          # DecisionReviewIssue is stored at since the index order could change when Github Actions runs
          case issue.contention_id
          when 123_456_789
            expect(issue.contention_id).to eq(123_456_789)
            expect(issue.associated_caseflow_decision_id).to eq(nil)
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(12)
            expect(issue.prior_decision_award_event_id).to eq(17_945)
            expect(issue.prior_decision_ramp_id).to eq(nil)
            expect(issue.prior_decision_text).to eq("DIC: Service connection for tetnus denied")
            expect(issue.prior_decision_type).to eq("DIC")
            expect(issue.prior_decision_notification_date).to eq(1954)
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_disability_sequence_number).to eq(nil)
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
          when 123_456_790
            expect(issue.contention_id).to eq(123_456_790)
            expect(issue.associated_caseflow_decision_id).to eq(nil)
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(13)
            expect(issue.prior_decision_award_event_id).to eq(17_945)
            expect(issue.prior_decision_ramp_id).to eq(nil)
            expect(issue.prior_decision_text).to eq("Basic Eligibility: Service connection for ear infection denied")
            expect(issue.prior_decision_type).to eq("Basic Eligibility")
            expect(issue.prior_decision_notification_date).to eq(1954)
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_disability_sequence_number).to eq(nil)
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
          end
        end
      end

      it "does not raise ArgumentError" do
        expect { subject }.not_to raise_error
      end
    end

    context "when DecisionReviewCreated portion of message_payload is invalid" do
      context "because payload is nil" do
        let(:nil_message_payload) { build(:decision_review_created, :nil) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { nil_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:empty_message_payload) { build(:decision_review_created, :empty) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { empty_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute name(s)" do
        let(:message_payload_with_invalid_attribute_name) { build(:decision_review_created, :invalid_attribute_name) }

        it "raises ArgumentError with message: Unknown attributes: unknown_attributes" do
          error_message = "DecisionReviewCreated: Unknown attributes - invalid_attribute"
          expect { message_payload_with_invalid_attribute_name }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute data type(s)" do
        let(:message_payload_with_invalid_data_type) { build(:decision_review_created, :invalid_data_type) }

        it "raises ArgumentError with message: class_name: name must be one of the allowed types, got class." do
          error_message = "DecisionReviewCreated: claim_id must be one of the allowed types - [Integer], got String"
          expect { message_payload_with_invalid_data_type }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues is an empty array" do
        let(:message_payload_without_decision_review_issues) do
          build(:decision_review_created, :without_decision_review_issues)
        end

        it "raises ArgumentError with message: DecisionReviewCreated: Message payload must include at least one"\
           " decision review issue" do
          error_message = "DecisionReviewCreated: Message payload must include at least one decision review issue"
          expect { message_payload_without_decision_review_issues }.to raise_error(ArgumentError, error_message)
        end
      end
    end

    context "when DecisionReviewIssue portion of message_payload is invalid" do
      context "because payload is nil" do
        let(:message_payload_with_nil_issue) { build(:decision_review_created, :with_nil_decision_review_issue) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssue: Message payload cannot be empty or nil"
          expect { message_payload_with_nil_issue }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:message_payload_with_empty_issue) { build(:decision_review_created, :with_empty_decision_review_issue) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssue: Message payload cannot be empty or nil"
          expect { message_payload_with_empty_issue }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute name(s)" do
        let(:message_payload_with_invalid_issue_attr_name) do
          build(:decision_review_created, :with_invalid_decision_review_issue_attribute_name)
        end

        it "raises ArgumentError with message: class_name: Unknown attributes - unknown_attributes" do
          error_message = "DecisionReviewIssue: Unknown attributes - invalid_attribute"
          expect { message_payload_with_invalid_issue_attr_name }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute data type(s)" do
        let(:message_payload_with_invalid_issue_data_type) do
          build(:decision_review_created, :with_invalid_decision_review_issue_data_type)
        end

        it "raises ArgumentError with message: class_name: name must be one of the allowed types -, got class." do
          error_message = "DecisionReviewIssue: contention_id must be one of the allowed types - [Integer, NilClass]," \
                          " got String"
          expect { message_payload_with_invalid_issue_data_type }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
