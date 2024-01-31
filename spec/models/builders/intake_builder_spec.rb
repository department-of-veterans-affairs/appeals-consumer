# frozen_string_literal: true

describe Builders::IntakeBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns an Intake object" do
      expect(subject).to be_an_instance_of(Intake)
    end
  end

  describe "#initialize" do
    let(:intake) { described_class.new.intake }
    it "initializes a new IntakeBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Intake object" do
      expect(intake).to be_an_instance_of(Intake)
    end
  end

  describe "#assign_attributes(decision_review_created)" do
    it "calls private methods" do
      allow(builder).to receive(:assign_started_at)
      allow(builder).to receive(:assign_completion_started_at)
      allow(builder).to receive(:assign_completed_at)
      allow(builder).to receive(:assign_completion_status)
      allow(builder).to receive(:calculate_type)

      builder.assign_attributes(decision_review_created)

      expect(builder).to have_received(:assign_started_at).with(decision_review_created)
      expect(builder).to have_received(:assign_completion_started_at).with(decision_review_created)
      expect(builder).to have_received(:assign_completed_at).with(decision_review_created)
      expect(builder).to have_received(:assign_completion_status)
      expect(builder).to have_received(:calculate_type).with(decision_review_created)
    end
  end
end
