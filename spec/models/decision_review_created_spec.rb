# frozen_string_literal: true

require "rails_helper"
require "timecop"
require "./app/models/decision_review_created"

describe DecisionReviewCreated do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  subject { described_class.new(message_payload) }

  let!(:issues_array) do
    [
      {
        contention_id: 123_456_789,
        associated_caseflow_request_issue_id: nil,
        unidentified: false,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: 12,
        prior_decision_text: "service connection for tetnus denied",
        prior_decision_type: "DIC",
        prior_decision_notification_date: Date.new(2022, 1, 1),
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil
      },
      {
        contention_id: 987_654_321,
        associated_caseflow_request_issue_id: nil,
        unidentified: false,
        prior_rating_decision_id: nil,
        prior_non_rating_decision_id: 13,
        prior_decision_text: "service connection for ear infection denied",
        prior_decision_type: "Basic Eligibility",
        prior_decision_notification_date: Date.new(2022, 1, 1),
        prior_decision_diagnostic_code: nil,
        prior_decision_rating_percentage: nil,
        eligible: true,
        eligibility_result: "ELIGIBLE",
        time_override: nil,
        time_override_reason: nil,
        contested: nil,
        soc_opt_in: nil,
        legacy_appeal_id: nil,
        legacy_appeal_issue_id: nil
      }
    ]
  end

  let!(:message_payload) do
    {
      claim_id: 1_234_567,
      decision_review_type: "HigherLevelReview",
      veteran_first_name: "John",
      veteran_last_name: "Smith",
      veteran_participant_id: "123456789",
      veteran_file_number: "123456789",
      claimant_participant_id: "01010101",
      ep_code: "030HLRNR",
      ep_code_category: "Rating",
      claim_received_date: Date.new(2022, 1, 1),
      claim_lifecycle_status: "RFD",
      payee_code: "00",
      modifier: "01",
      originated_from_vacols_issue: false,
      informal_conference_requested: false,
      same_station_requested: false,
      intake_creation_time: Time.now.utc,
      claim_creation_time: Time.now.utc,
      created_by_username: "BVADWISE101",
      created_by_station: "101",
      created_by_application: "PASYSACCTCREATE",
      decision_review_issues: issues_array
    }
  end

  describe "#initialize" do
    context "when DecisionReviewCreated and DecisionReviewIssue portions of payload have valid attributes and
            data types" do
      it "initializes a DecisionReviewCreated object" do
        expect(subject.claim_id).to eq(1_234_567)
        expect(subject.decision_review_type).to eq("HigherLevelReview")
        expect(subject.veteran_first_name).to eq("John")
        expect(subject.veteran_last_name).to eq("Smith")
        expect(subject.veteran_participant_id).to eq("123456789")
        expect(subject.veteran_file_number).to eq("123456789")
        expect(subject.claimant_participant_id).to eq("01010101")
        expect(subject.ep_code).to eq("030HLRNR")
        expect(subject.ep_code_category).to eq("Rating")
        expect(subject.claim_received_date).to eq(Date.new(2022, 1, 1))
        expect(subject.claim_lifecycle_status).to eq("RFD")
        expect(subject.payee_code).to eq("00")
        expect(subject.modifier).to eq("01")
        expect(subject.originated_from_vacols_issue).to eq(false)
        expect(subject.informal_conference_requested).to eq(false)
        expect(subject.same_station_requested).to eq(false)
        expect(subject.intake_creation_time).to eq(Time.now.utc)
        expect(subject.claim_creation_time).to eq(Time.now.utc)
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
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(12)
            expect(issue.prior_decision_text).to eq("service connection for tetnus denied")
            expect(issue.prior_decision_type).to eq("DIC")
            expect(issue.prior_decision_notification_date).to eq(Date.new(2022, 1, 1))
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_percentage).to eq(nil)
            expect(issue.eligible).to eq(true)
            expect(issue.eligibility_result).to eq("ELIGIBLE")
            expect(issue.time_override).to eq(nil)
            expect(issue.time_override_reason).to eq(nil)
            expect(issue.contested).to eq(nil)
            expect(issue.soc_opt_in).to eq(nil)
            expect(issue.legacy_appeal_id).to eq(nil)
            expect(issue.legacy_appeal_issue_id).to eq(nil)
          when 987_654_321
            expect(issue.contention_id).to eq(987_654_321)
            expect(issue.associated_caseflow_request_issue_id).to eq(nil)
            expect(issue.unidentified).to eq(false)
            expect(issue.prior_rating_decision_id).to eq(nil)
            expect(issue.prior_non_rating_decision_id).to eq(13)
            expect(issue.prior_decision_text).to eq("service connection for ear infection denied")
            expect(issue.prior_decision_type).to eq("Basic Eligibility")
            expect(issue.prior_decision_notification_date).to eq(Date.new(2022, 1, 1))
            expect(issue.prior_decision_diagnostic_code).to eq(nil)
            expect(issue.prior_decision_rating_percentage).to eq(nil)
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
        let(:message_payload) { nil }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        let(:message_payload) { {} }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute name(s)" do
        before do
          message_payload[:first_invalid_attribute] = "causes initialization to fail"
          message_payload[:second_invalid_attribute] = "causes initialization to fail"
        end

        it "raises ArgumentError with message: Unknown attributes: unknown_attributes" do
          error_message = "DecisionReviewCreated: Unknown attributes - first_invalid_attribute," \
                          " second_invalid_attribute"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute data type(s)" do
        before do
          message_payload[:claim_id] = "invalid data type"
        end

        it "raises ArgumentError with message: class_name: name must be one of the allowed types, got class." do
          error_message = "DecisionReviewCreated: claim_id must be one of the allowed types - [Integer], got String"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because decision_review_issues is an empty array" do
        before do
          message_payload[:decision_review_issues] = []
        end

        it "raises ArgumentError with message: DecisionReviewCreated: Message payload must include at least one"\
           " decision review issue" do
          error_message = "DecisionReviewCreated: Message payload must include at least one decision review issue"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end
    end

    context "when DecisionReviewIssue portion of message_payload is invalid" do
      context "because payload is nil" do
        before do
          message_payload[:decision_review_issues][0] = nil
        end

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssue: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload is empty" do
        before do
          message_payload[:decision_review_issues][1] = {}
        end

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewIssue: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute name(s)" do
        before do
          issues_array.each do |issue_obj|
            issue_obj[:first_invalid_attribute] = "causes initialization to fail"
            issue_obj[:second_invalid_attribute] = "causes initialization to fail"
          end
        end

        it "raises ArgumentError with message: class_name: Unknown attributes - unknown_attributes" do
          error_message = "DecisionReviewIssue: Unknown attributes - first_invalid_attribute, second_invalid_attribute"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because payload has invalid attribute data type(s)" do
        before do
          issues_array.each do |issue_obj|
            issue_obj[:contention_id] = "invalid data type"
          end
        end

        it "raises ArgumentError with message: class_name: name must be one of the allowed types -, got class." do
          error_message = "DecisionReviewIssue: contention_id must be one of the allowed types - [Integer, NilClass]," \
                          " got String"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end

  describe "#attribute_types" do
    let!(:drc_attribute_types) do
      subject.send(:attribute_types)
    end

    let!(:dri_attribute_types) do
      DecisionReviewIssue.new(issues_array.first).send(:attribute_types)
    end

    it "returns a frozen attribute_types hash for both classes" do
      expect(drc_attribute_types).to be_frozen
      expect(dri_attribute_types).to be_frozen
    end

    it "raises a FrozenError when attempting to modify the hashes" do
      expect { drc_attribute_types[:invalid_attribute] = String }.to raise_error(FrozenError)
      expect { dri_attribute_types[:invalid_attribute] = String }.to raise_error(FrozenError)
      expect { drc_attribute_types[:claim_id] = String }.to raise_error(FrozenError)
      expect { dri_attribute_types[:contention_id] = String }.to raise_error(FrozenError)
    end
  end
end
