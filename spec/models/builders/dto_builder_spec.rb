# frozen_string_literal: true

RSpec.describe Builders::DtoBuilder, type: :model do
  subject { Builders::DtoBuilder.new }

  describe "#clean_pii" do
    context "when there are multiple PII attributes on an instance of a payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "ssn": "111111",
          "date_of_birth": Time.current
        }.as_json
      end

      it "should return a hash of a model without any PII fields" do
        clean_hash = { "id": 1 }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
    context "when a PII field is an attribute on an instance of a payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "ssn": "111111"
        }.as_json
      end
      it "should return a hash of a model without any PII fields" do
        clean_hash = { "id": 1 }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
    context "when there are deep PII fields in instance of payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "person": {
            "p_id": 1,
            "ssn": "111111"
          }
        }.as_json
      end
      it "shoud return a hash of a model without any PII fields" do
        clean_hash = {"id": 1, "person": {"p_id": 1}}.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
    context "when there is no PII attribute on an instance of a payload model" do
      it "should return a hash of a model without any PII fields" do
        #byebug
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