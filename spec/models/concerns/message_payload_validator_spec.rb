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
          error_message = "Transformers::DecisionReviewCreated: Message payload cannot be empty or nil"
          expect { nil_message_payload }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because message payload is empty" do
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

      context "because there are invalid attribute data type(s)" do
        let(:message_payload_with_invalid_data_type) { build(:decision_review_created, :invalid_data_type) }

        it "raises an ArgumentError with message: class_name: name must be one of the allowed types, got value.class" do
          error_message = "Transformers::DecisionReviewCreated: claim_id must be one of the allowed types - "\
          "[Integer], got String"
          expect { message_payload_with_invalid_data_type }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
