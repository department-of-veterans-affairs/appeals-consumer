# frozen_string_literal: true

require "./app/models/concerns/message_payload_validator"

describe MessagePayloadValidator do
  describe "#validate" do
    context "when the message payload has valid attribute names and data types" do
      let(:valid_message_payload) { build(:decision_review_created) }

      it "does not raise ArgumentError" do
        expect { valid_message_payload }.not_to raise_error
      end
    end

    context "when the message payload is invalid" do
      context "because message payload is nil" do
        let(:nil_message_payload) { build(:decision_review_created, :nil) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { nil_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because message payload is empty" do
        let(:empty_message_payload) { build(:decision_review_created, :empty) }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { empty_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute name(s)" do
        let(:message_payload_with_invalid_attribute_name) { build(:decision_review_created, :invalid_attribute_name) }

        it "raises an ArgumentError with message: class_name: Unknown attributes - unknown_attributes" do
          error_message = "DecisionReviewCreated: Unknown attributes - invalid_attribute"
          expect { message_payload_with_invalid_attribute_name }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute data type(s)" do
        let(:message_payload_with_invalid_data_type) { build(:decision_review_created, :invalid_data_type) }

        it "raises an ArgumentError with message: class_name: name must be one of the allowed types, got value.class" do
          error_message = "DecisionReviewCreated: claim_id must be one of the allowed types - [Integer], got String"
          expect { message_payload_with_invalid_data_type }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
