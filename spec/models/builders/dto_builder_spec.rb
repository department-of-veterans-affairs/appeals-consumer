# frozen_string_literal: true

RSpec.describe Builders::DtoBuilder, type: :model do
  describe "#clean_pii" do
    context "when there are multiple PII attributes on an instance of a payload model" do
      it "should return a hash of a model without any PII fields" do
      end
    end
    context "when a PII field is an attribute on an instance of a payload model" do
      it "should return a hash of a model without any PII fields" do
      end
    end
    context "when there is no PII attribute on an instance of a payload model" do
      it "should return a hash of a model without any PII fields" do
      end
    end
  end

  describe "#validate_no_pii" do
    context "when no PII field is found in the hash_response" do
      it "should return an unchanged hash_response" do
      end
    end
    context "when there IS A PII field found in the hash_response" do
      it "should throw a PIIFoundViolationError" do
      end
    end
  end
end