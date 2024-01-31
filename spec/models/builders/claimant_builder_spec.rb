# frozen_string_literal: true

describe Builders::ClaimantBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a Claimant object" do
      expect(subject).to be_an_instance_of(Claimant)
    end
  end

  describe "#initialize" do
    let(:claimant) { described_class.new.claimant }

    it "initializes a new ClaimantBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Claimant object" do
      expect(claimant).to be_an_instance_of(Claimant)
    end
  end

  describe "#assign_attributes(decision_review_created)" do
    it "calls private methods" do
      allow(builder).to receive(:assign_payee_code)
      allow(builder).to receive(:calculate_type)
      allow(builder).to receive(:assign_participant_id)
      allow(builder).to receive(:calculate_name_suffix)
      allow(builder).to receive(:calculate_ssn)
      allow(builder).to receive(:calculate_date_of_birth)
      allow(builder).to receive(:calculate_first_name)
      allow(builder).to receive(:calculate_middle_name)
      allow(builder).to receive(:calculate_last_name)
      allow(builder).to receive(:calculate_email)

      builder.assign_attributes(decision_review_created)

      expect(builder).to have_received(:assign_payee_code).with(decision_review_created)
      expect(builder).to have_received(:calculate_type).with(decision_review_created)
      expect(builder).to have_received(:assign_participant_id).with(decision_review_created)
      expect(builder).to have_received(:calculate_name_suffix).with(decision_review_created)
      expect(builder).to have_received(:calculate_ssn).with(decision_review_created)
      expect(builder).to have_received(:calculate_date_of_birth).with(decision_review_created)
      expect(builder).to have_received(:calculate_first_name).with(decision_review_created)
      expect(builder).to have_received(:calculate_middle_name).with(decision_review_created)
      expect(builder).to have_received(:calculate_last_name).with(decision_review_created)
      expect(builder).to have_received(:calculate_email).with(decision_review_created)
    end
  end
end
