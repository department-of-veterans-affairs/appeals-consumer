# frozen_string_literal: true

describe Builders::IntakeBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let(:intake_creation_time_converted_to_timestamp_ms) do
    builder.convert_to_timestamp_ms(decision_review_created.intake_creation_time)
  end
  let(:claim_creation_time_converted_to_timestamp_ms) do
    builder.claim_creation_time_converted_to_timestamp_ms
  end

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
      expect(builder).to receive(:calculate_started_at)
      expect(builder).to receive(:calculate_completion_started_at)
      expect(builder).to receive(:calculate_completed_at)
      expect(builder).to receive(:assign_completion_status)
      expect(builder).to receive(:calculate_type)

      builder.assign_attributes
    end
  end

  describe "private methods" do
    let(:decision_review_created) { build(:decision_review_created) }
    let(:builder) { described_class.new(decision_review_created) }

    describe "#_calculate_started_at" do
      it "should assign @intake.started_at" do
        builder.send(:calculate_started_at)
        expect(builder.instance_variable_get(:@intake).started_at).to eq intake_creation_time_converted_to_timestamp_ms
      end
    end

    describe "#_calculate_completion_started_at" do
      it "should assign @completion_started_at" do
        builder.send(:calculate_completion_started_at)
        expect(builder.instance_variable_get(:@intake).completion_started_at)
          .to eq claim_creation_time_converted_to_timestamp_ms
      end
    end

    describe "#_calculate_completed_at" do
      it "should assign @completion_completed_at" do
        builder.send(:calculate_completed_at)
        expect(builder.instance_variable_get(:@intake).completed_at)
          .to eq claim_creation_time_converted_to_timestamp_ms
      end
    end

    describe "#_assign_completion_status" do
      it "should assign @completed_status" do
        builder.send(:assign_completion_status)
        expect(builder.instance_variable_get(:@intake).completion_status).to eq "success"
      end
    end

    describe "#_calculate_type" do
      it "should assign @type" do
        builder.send(:calculate_type)
        expect(builder.instance_variable_get(:@intake).type).to eq "HigherLevelReviewIntake"
        decision_review_created.instance_variable_set(:@decision_review_type, "SUPPLEMENTAL_CLAIM")
        builder.instance_variable_set(:@decision_review_created, decision_review_created)
        builder.send(:calculate_type)
        expect(builder.instance_variable_get(:@intake).type).to eq "SupplementalClaimIntake"
      end
    end

    describe "#_calculate_detail_type" do
      it "should assign @detail_type" do
        builder.send(:calculate_detail_type)
        expect(builder.instance_variable_get(:@intake).detail_type).to eq "HigherLevelReview"
        decision_review_created.instance_variable_set(:@decision_review_type, "SUPPLEMENTAL_CLAIM")
        builder.instance_variable_set(:@decision_review_created, decision_review_created)
        builder.send(:calculate_detail_type)
        expect(builder.instance_variable_get(:@intake).detail_type).to eq "SupplementalClaim"
      end
    end
  end
end
