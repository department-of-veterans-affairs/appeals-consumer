# frozen_string_literal: true

describe Builders::ClaimantBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    subject { described_class.build(decision_review_created) }

    it "returns a Claimant object" do
      expect(subject).to be_an_instance_of(Claimant)
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:claimant) { described_class.new.claimant }

    it "initializes a new ClaimantBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Claimant object" do
      expect(claimant).to be_an_instance_of(Claimant)
    end
  end
end
