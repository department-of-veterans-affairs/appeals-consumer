# frozen_string_literal: true

describe Builders::IntakeBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    subject { described_class.build(decision_review_created) }

    it "returns an Intake object" do
      expect(subject).to be_an_instance_of(Intake)
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:intake) { described_class.new.intake }

    it "initializes a new IntakeBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Intake object" do
      expect(intake).to be_an_instance_of(Intake)
    end
  end
end
