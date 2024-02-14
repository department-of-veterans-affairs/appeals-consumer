# frozen_string_literal: true

describe Builders::ClaimReviewBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a ClaimReview object" do
      expect(subject).to be_an_instance_of(ClaimReview)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:claim_review) { described_class.new(decision_review_created).claim_review }

    it "initializes a new ClaimReviewBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new ClaimReview object" do
      expect(claim_review).to be_an_instance_of(ClaimReview)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:calculate_benefit_type)
      expect(builder).to receive(:assign_filed_by_va_gov)
      expect(builder).to receive(:assign_receipt_date)
      expect(builder).to receive(:calculate_legacy_opt_in_approved)
      expect(builder).to receive(:calculate_veteran_is_not_claimant)
      expect(builder).to receive(:assign_establishment_attempted_at)
      expect(builder).to receive(:assign_establishment_last_submitted_at)
      expect(builder).to receive(:assign_establishment_processed_at)
      expect(builder).to receive(:assign_establishment_submitted_at)
      expect(builder).to receive(:assign_informal_conference)
      expect(builder).to receive(:assign_same_office)

      builder.assign_attributes
    end
  end

  describe "#calculate_benefit_type" do
    subject { builder.send(:calculate_benefit_type) }

    context "when decision_review_created.ep_code includes 'PMC'" do
      let(:decision_review_created) { build(:decision_review_created, :pension) }
      it "assigns the claim_review's benefit_type to 'pension'" do
        expect(subject).to eq(Builders::ClaimReviewBuilder::PENSION_BENEFIT_TYPE)
      end
    end

    context "when decision_review_created.ep_code DOES NOT include 'PMC'" do
      it "assigns the claim_review's benefit_type to 'compensation'" do
        expect(subject).to eq(Builders::ClaimReviewBuilder::COMPENSATION_BENEFIT_TYPE)
      end
    end
  end

  describe "#assign_filed_by_va_gov" do
    subject { builder.send(:assign_filed_by_va_gov) }
    it "always assigns claim_review's filed_by_va_gov to false" do
      expect(subject).to eq(Builders::ClaimReviewBuilder::FILED_BY_VA_GOV)
    end
  end

  describe "#assign_receipt_date" do
    subject { builder.send(:assign_receipt_date) }
    it "assigns claim_review's receipt_date to decision_review_created.claim_received_date" do
      expect(subject).to eq(decision_review_created.claim_received_date)
    end
  end

  describe "#calculate_legacy_opt_in_approved" do
    subject { builder.send(:calculate_legacy_opt_in_approved) }

    context "when decision_review_created contains a decision_review_issue with soc_opt_in: true" do
      let(:decision_review_created) { build(:decision_review_created, :soc_opt_in) }

      it "assigns claim_review's legacy_opt_in_approved to true" do
        expect(subject).to eq(true)
      end
    end

    context "when decision_review_created DOES NOT contain a decision_review_issue with soc_opt_in: true" do
      it "assigns claim_review's legacy_opt_in_approved to false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#calculate_veteran_is_not_claimant" do
    subject { builder.send(:calculate_veteran_is_not_claimant) }

    context "when decision_review_created.veteran_participant_id is NOT the same as"\
      " decision_review_created.claimant_participant_id" do
      it "assigns claim_review's veteran_is_not_claimant to true" do
        expect(subject).to eq true
      end
    end

    context "when decision_review_created.veteran_participant_id is the same as"\
      " decision_review_created.claimant_participant_id" do
      let(:decision_review_created) { build(:decision_review_created, :veteran_is_claimant) }
      it "assigns claim_review's veteran_is_not_claimant to true" do
        expect(subject).to eq false
      end
    end
  end

  describe "#assign_establishment_attempted_at" do
    subject { builder.send(:assign_establishment_attempted_at) }

    it "assigns claim_review's establishment_attempted_at to decision_review_created.claim_creation_time" do
      expect(subject).to eq(decision_review_created.claim_creation_time)
    end
  end

  describe "#assign_establishment_last_submitted_at" do
    subject { builder.send(:assign_establishment_last_submitted_at) }

    it "assigns claim_review's establishment_last_submitted_at to decision_review_created.claim_creation_time" do
      expect(subject).to eq(decision_review_created.claim_creation_time)
    end
  end

  describe "#assign_establishment_processed_at" do
    subject { builder.send(:assign_establishment_processed_at) }

    it "assigns claim_review's establishment_processed_at to decision_review_created.claim_creation_time" do
      expect(subject).to eq(decision_review_created.claim_creation_time)
    end
  end

  describe "#assign_establishment_submitted_at" do
    subject { builder.send(:assign_establishment_submitted_at) }

    it "assigns claim_review's establishment_submitted_at to decision_review_created.claim_creation_time" do
      expect(subject).to eq(decision_review_created.claim_creation_time)
    end
  end

  describe "#assign_informal_conference" do
    subject { builder.send(:assign_informal_conference) }
    it "assigns claim_review's informal_conference to decision_reciew_created.informal_conference_requested" do
      expect(subject).to eq(decision_review_created.informal_conference_requested)
    end
  end

  describe "#assign_same_office" do
    subject { builder.send(:assign_same_office) }
    it "assigns claim_review's same_office to decision_reciew_created.same_station_review_requested" do
      expect(subject).to eq(decision_review_created.same_station_review_requested)
    end
  end
end
