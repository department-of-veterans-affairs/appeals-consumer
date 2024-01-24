# frozen_string_literal: true

require "rails_helper"
require "./app/models/concerns/message_payload_validator"

describe MessagePayloadValidator do
  subject(:decision_review_created) { DecisionReviewCreated.new(message_payload) }

  let!(:issues_array) do
    [
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

  describe "#validate" do
    context "when the message payload has valid attribute names and data types" do
      it "does not raise ArgumentError" do
        expect { subject }.not_to raise_error
      end
    end

    context "when the message payload is invalid" do
      context "because message payload is nil" do
        let(:message_payload) { nil }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because message payload is empty" do
        let(:message_payload) { {} }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute name(s)" do
        before do
          message_payload[:invalid_attribute] = "is invalid"
        end

        it "raises an ArgumentError with message: class_name: Unknown attributes - unknown_attributes" do
          error_message = "DecisionReviewCreated: Unknown attributes - invalid_attribute"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute data type(s)" do
        before do
          message_payload[:claim_id] = "123456789"
        end

        it "raises an ArgumentError with message: class_name: name must be one of the allowed types, got value.class" do
          error_message = "DecisionReviewCreated: claim_id must be one of the allowed types - [Integer], got String"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
