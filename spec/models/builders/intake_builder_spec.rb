# frozen_string_literal: true

describe Builders::IntakeBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns an Intake object" do
      expect(subject).to be_an_instance_of(Intake)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:intake) { described_class.new(decision_review_created).intake }
    it "initializes a new IntakeBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Intake object" do
      expect(intake).to be_an_instance_of(Intake)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:assign_started_at)
      expect(builder).to receive(:assign_completion_started_at)
      expect(builder).to receive(:assign_completed_at)
      expect(builder).to receive(:assign_completion_status)
      expect(builder).to receive(:calculate_type)

      builder.assign_attributes
    end
  end
end
