# frozen_string_literal: true

describe Builders::VeteranBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    subject { described_class.build(decision_review_created) }

    it "returns a Veteran object" do
      expect(subject).to be_an_instance_of(Veteran)
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:veteran) { described_class.new.veteran }

    it "initializes a new VeteranBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Veteran object" do
      expect(veteran).to be_an_instance_of(Veteran)
    end
  end
end
