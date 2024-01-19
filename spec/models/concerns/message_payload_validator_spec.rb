# frozen_string_literal: true
require "simplecov"
SimpleCov.start
require "rails_helper"
require "./app/models/concerns/message_payload_validator"

class DummyClass
  include MessagePayloadValidator

  def attribute_types
    {
      attribute_one: String,
      attribute_two: [String, NilClass],
      attribute_three: Integer,
      attribute_four: [TrueClass, FalseClass]
    }
  end
end

describe MessagePayloadValidator do
  subject(:dummy_class) { DummyClass.new.validate(message_payload, DummyClass) }

  describe "#validate" do
    context "when the message payload has valid attribute names and data types" do
      let(:message_payload) do
        {
          attribute_one: "is valid",
          attribute_two: nil,
          attribute_three: 3,
          attribute_four: true
        }
      end

      it "does not raise ArgumentError" do
        expect { subject }.not_to raise_error
      end
    end

    context "when the message payload is invalid" do
      context "because message payload is nil" do
        let(:message_payload) { {} }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DummyClass: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because message payload is empty" do
        let(:message_payload) { nil }

        it "raises ArgumentError with message: class_name: Message payload cannot be empty or nil" do
          error_message = "DummyClass: Message payload cannot be empty or nil"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute name(s)" do
        let(:message_payload) do
          {
            attribute_zero: "causes a failure",
            attribute_one: "is valid",
            attribute_two: nil,
            attribute_three: 3,
            attribute_four: true
          }
        end

        it "raises an ArgumentError with message: class_name: Unknown attributes - unknown_attributes" do
          error_message = "DummyClass: Unknown attributes - attribute_zero"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end

      context "because there are invalid attribute data type(s)" do
        let(:message_payload) do
          {
            attribute_one: "is valid",
            attribute_two: nil,
            attribute_three: "is supposed to be an integer",
            attribute_four: true
          }
        end

        it "raises an ArgumentError with message: class_name: name must be one of the allowed types, got value.class" do
          error_message = "DummyClass: attribute_three must be one of the allowed types - [Integer], got String"
          expect { subject }.to raise_error(ArgumentError, error_message)
        end
      end
    end
  end
end
