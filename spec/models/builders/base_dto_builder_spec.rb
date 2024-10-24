# frozen_string_literal: true

RSpec.describe Builders::BaseDtoBuilder, type: :model do
  subject { Builders::BaseDtoBuilder.new }

  describe "PII_FIELDS" do
    it "should include all the listed pii fields" do
      expect(subject.class::PII_FIELDS).to eq %w[
        ssn
        filenumber
        file_number
        first_name
        middle_name
        last_name
        date_of_birth
        email
      ]
    end
  end

  # accepts instance of model which is then converted to a hash via `.as_json`,
  # but tested here mostly with a hash already to show depth field cleaning
  describe "#clean_pii" do
    context "when there are multiple PII attributes on an instance of a payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "ssn": "111111",
          "date_of_birth": Time.current
        }.as_json
      end
      let(:veteran) { build(:veteran) }

      it "should return a hash of a model without any PII fields" do
        clean_hash = { "id": 1 }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
        expect((subject.clean_pii(veteran).keys & subject.class::PII_FIELDS).blank?).to eq true
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
    context "when there is a single deep PII fields in instance of payload model" do
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
        clean_hash = { "id": 1, "person": { "p_id": 1 } }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
    context "when there are multple deep PII fields in instance of payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "person": {
            "p_id": 1,
            "filenumber": "22222",
            "ssn_obj": {
              "ssn": "11111"
            }
          }
        }.as_json
      end

      it "shoud return a hash of a model without any PII fields" do
        clean_hash = { "id": 1, "person": { "p_id": 1, "ssn_obj": {} } }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
    context "when there is no PII attribute on an instance of a payload model" do
      let(:sample_hash) do
        {
          "id": 1,
          "type": "some_type",
          "location": "some_location"
        }.as_json
      end

      it "should return a hash of a model without any PII fields" do
        clean_hash = { "id": 1, "type": "some_type", "location": "some_location" }.as_json
        expect(subject.clean_pii(sample_hash)).to eq clean_hash
      end
    end
  end

  # accepts hash
  describe "#validate_no_pii" do
    context "when no PII field is found in the payload" do
      let(:sample_hash) do
        {
          "id": 1,
          "type": "some_type",
          "location": "some_location"
        }.as_json
      end

      it "should return an unchanged payload" do
        expect(subject.validate_no_pii(sample_hash)).to eq sample_hash
      end
    end
    context "when there IS A PII field found in the payload" do
      let(:sample_hash) do
        {
          "id": 1,
          "type": "some_type",
          "location": "some_location",
          "ssn": "111111"
        }.as_json
      end
      it "should throw a PIIFoundViolationError" do
        expect { subject.validate_no_pii(sample_hash) }.to raise_error(AppealsConsumer::Error::PIIFoundViolationError)
      end
    end
  end

  describe "#calculate_and_format_detail_type" do
    context "when the decision_review_type from a DecisionReview event is 'HIGHER_LEVEL_REVIEW'" do
      let(:hlr_decision_review_type) { "HIGHER_LEVEL_REVIEW" }
      let(:formatted_hlr_decision_review_type) { "HigherLevelReview" }

      it "should return 'HigherLevelReview' formatted in pascal case" do
        expect(subject.calculate_and_format_detail_type(hlr_decision_review_type))
          .to eq formatted_hlr_decision_review_type
      end
    end
    context "when the decision_review_type from DecisionReview event is 'SUPPLEMENTAL_CLAIM'" do
      let(:sc_decision_review_type) { "SUPPLEMENTAL_CLAIM" }
      let(:formatted_sc_decision_review_type) { "SupplementalClaim" }
      it "should return 'SupplementalClaim' formatted in pascal case" do
        expect(subject.calculate_and_format_detail_type(sc_decision_review_type))
          .to eq formatted_sc_decision_review_type
      end
    end
  end
end
