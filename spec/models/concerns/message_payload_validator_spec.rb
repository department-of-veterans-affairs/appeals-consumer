# frozen_string_literal: true

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
  subject(:dummy_class) { DummyClass.new }

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
        expect { dummy_class.validate(message_payload) }.not_to raise_error
      end
    end

    context "when the message payload has invalid attribute name(s)" do
      let(:message_payload) do
        {
          attribute_zero: "causes a failure",
          attribute_one: "is valid",
          attribute_two: nil,
          attribute_three: 3,
          attribute_four: true
        }
      end

      it "raises an ArgumentError with message: Unknown attributes: unknown_attributes" do
        error_message = "Unknown attributes: attribute_zero"
        expect { dummy_class.validate(message_payload) }.to raise_error(ArgumentError, error_message)
      end
    end

    context "when the message payload has invalid attribute data type(s)" do
      let(:message_payload) do
        {
          attribute_one: "is valid",
          attribute_two: nil,
          attribute_three: "is supposed to be an integer",
          attribute_four: true
        }
      end

      it "raises an ArgumentError with message: name must be one of the allowed types, got value.class" do
        error_message = "attribute_three must be one of the allowed types [Integer], got String."
        expect { dummy_class.validate(message_payload) }.to raise_error(ArgumentError, error_message)
      end
    end
  end
end
