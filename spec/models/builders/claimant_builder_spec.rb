# frozen_string_literal: true

describe Builders::ClaimantBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a Claimant object" do
      expect(subject).to be_an_instance_of(Claimant)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:claimant) { described_class.new(decision_review_created).claimant }

    it "initializes a new ClaimantBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Claimant object" do
      expect(claimant).to be_an_instance_of(Claimant)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:assign_payee_code)
      expect(builder).to receive(:calculate_type)
      expect(builder).to receive(:assign_participant_id)
      expect(builder).to receive(:calculate_name_suffix)
      expect(builder).to receive(:calculate_ssn)
      expect(builder).to receive(:calculate_date_of_birth)
      expect(builder).to receive(:calculate_first_name)
      expect(builder).to receive(:calculate_middle_name)
      expect(builder).to receive(:calculate_last_name)
      expect(builder).to receive(:calculate_email)

      builder.assign_attributes
    end
  end
end
