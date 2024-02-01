# frozen_string_literal: true

describe Builders::VeteranBuilder do
  let!(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a Veteran object" do
      expect(subject).to be_an_instance_of(Veteran)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:veteran) { described_class.new(decision_review_created).veteran }

    it "initializes a new VeteranBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Veteran object" do
      expect(veteran).to be_an_instance_of(Veteran)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      allow(builder).to receive(:assign_participant_id)
      allow(builder).to receive(:calculate_bgs_last_synced_at)
      allow(builder).to receive(:calculate_closest_regional_office)
      allow(builder).to receive(:calculate_date_of_death)
      allow(builder).to receive(:calculate_date_of_death_reported_at)
      allow(builder).to receive(:calculate_name_suffix)
      allow(builder).to receive(:calculate_ssn)
      allow(builder).to receive(:assign_file_number)
      allow(builder).to receive(:assign_first_name)
      allow(builder).to receive(:calculate_middle_name)
      allow(builder).to receive(:assign_last_name)

      builder.assign_attributes

      expect(builder).to have_received(:assign_participant_id)
      expect(builder).to have_received(:calculate_bgs_last_synced_at)
      expect(builder).to have_received(:calculate_closest_regional_office)
      expect(builder).to have_received(:calculate_date_of_death)
      expect(builder).to have_received(:calculate_date_of_death_reported_at)
      expect(builder).to have_received(:calculate_name_suffix)
      expect(builder).to have_received(:calculate_ssn)
      expect(builder).to have_received(:assign_file_number)
      expect(builder).to have_received(:assign_first_name)
      expect(builder).to have_received(:calculate_middle_name)
      expect(builder).to have_received(:assign_last_name)
    end
  end
end
