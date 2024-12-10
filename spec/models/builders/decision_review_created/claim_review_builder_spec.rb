# frozen_string_literal: true

describe Builders::DecisionReviewCreated::ClaimReviewBuilder do
  let(:decision_review_model) { build(:decision_review_created, :test_claimant) }
  let(:builder) { described_class.new(decision_review_model) }
  let(:converted_claim_creation_time) { builder.send(:claim_creation_time_converted_to_timestamp_ms) }

  describe "#build" do
    subject { described_class.build(decision_review_model) }
    it "returns a DecisionReviewCreated::ClaimReview object" do
      expect(subject).to be_an_instance_of(DecisionReviewCreated::ClaimReview)
    end
  end

  describe "#initialize(decision_review_model)" do
    let(:claim_review) { described_class.new(decision_review_model).claim_review }

    it "initializes a new ClaimReviewBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new DecisionReviewCreated::ClaimReview object" do
      expect(claim_review).to be_an_instance_of(DecisionReviewCreated::ClaimReview)
    end

    it "assigns decision_review_model to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_model).to be_an_instance_of(Transformers::DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:calculate_benefit_type)
      expect(builder).to receive(:assign_filed_by_va_gov)
      expect(builder).to receive(:calculate_receipt_date)
      expect(builder).to receive(:calculate_legacy_opt_in_approved)
      expect(builder).to receive(:calculate_veteran_is_not_claimant)
      expect(builder).to receive(:calculate_establishment_attempted_at)
      expect(builder).to receive(:calculate_establishment_last_submitted_at)
      expect(builder).to receive(:calculate_establishment_processed_at)
      expect(builder).to receive(:calculate_establishment_submitted_at)
      expect(builder).to receive(:assign_informal_conference)
      expect(builder).to receive(:assign_same_office)
      expect(builder).to receive(:assign_auto_remand)

      builder.assign_attributes
    end
  end

  describe "#calculate_benefit_type" do
    subject { builder.send(:calculate_benefit_type) }

    context "when decision_review_model.ep_code includes 'PMC'" do
      let(:decision_review_model) { build(:decision_review_created, :nonrating_hlr_pension) }
      it "assigns the claim_review's benefit_type to 'pension'" do
        expect(subject).to eq(Builders::DecisionReviewCreated::ClaimReviewBuilder::PENSION_BENEFIT_TYPE)
      end
    end

    context "when decision_review_model.ep_code DOES NOT include 'PMC'" do
      it "assigns the claim_review's benefit_type to 'compensation'" do
        expect(subject).to eq(Builders::DecisionReviewCreated::ClaimReviewBuilder::COMPENSATION_BENEFIT_TYPE)
      end
    end
  end

  describe "#assign_filed_by_va_gov" do
    subject { builder.send(:assign_filed_by_va_gov) }
    it "always assigns claim_review's filed_by_va_gov to nil" do
      expect(subject).to eq(Builders::DecisionReviewCreated::ClaimReviewBuilder::FILED_BY_VA_GOV)
      expect(subject).to eq(nil)
    end
  end

  describe "#calculate_receipt_date" do
    subject { builder.send(:calculate_receipt_date) }
    let(:converted_claim_date) do
      builder.convert_to_date_logical_type(decision_review_model.claim_received_date)
    end
    it "assigns claim_review's receipt_date to decision_review_model.claim_received_date converted to date"\
     " logical type" do
      expect(subject).to eq(converted_claim_date)
    end
  end

  describe "#calculate_legacy_opt_in_approved" do
    subject { builder.send(:calculate_legacy_opt_in_approved) }

    context "when decision_review_model contains a decision_review_issue with soc_opt_in: true" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_legacy_appeal) }

      it "assigns claim_review's legacy_opt_in_approved to true" do
        expect(subject).to eq(true)
      end
    end

    context "when decision_review_model DOES NOT contain a decision_review_issue with soc_opt_in: true" do
      it "assigns claim_review's legacy_opt_in_approved to false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#calculate_veteran_is_not_claimant" do
    subject { builder.send(:calculate_veteran_is_not_claimant) }

    context "when decision_review_model.veteran_participant_id is NOT the same as"\
      " decision_review_model.claimant_participant_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_non_veteran_claimant) }
      it "assigns claim_review's veteran_is_not_claimant to true" do
        expect(subject).to eq true
      end
    end

    context "when decision_review_model.veteran_participant_id is the same as"\
      " decision_review_model.claimant_participant_id" do
      it "assigns claim_review's veteran_is_not_claimant to true" do
        expect(subject).to eq false
      end
    end
  end

  describe "#calculate_establishment_attempted_at" do
    subject { builder.send(:calculate_establishment_attempted_at) }

    it "assigns claim_review's establishment_attempted_at to decision_review_model.claim_creation_time" do
      expect(subject).to eq(converted_claim_creation_time)
    end
  end

  describe "#calculate_establishment_last_submitted_at" do
    subject { builder.send(:calculate_establishment_last_submitted_at) }

    it "assigns claim_review's establishment_last_submitted_at to decision_review_model.claim_creation_time" do
      expect(subject).to eq(converted_claim_creation_time)
    end
  end

  describe "#calculate_establishment_processed_at" do
    subject { builder.send(:calculate_establishment_processed_at) }

    it "assigns claim_review's establishment_processed_at to decision_review_model.claim_creation_time" do
      expect(subject).to eq(converted_claim_creation_time)
    end
  end

  describe "#calculate_establishment_submitted_at" do
    subject { builder.send(:calculate_establishment_submitted_at) }

    it "assigns claim_review's establishment_submitted_at to decision_review_model.claim_creation_time" do
      expect(subject).to eq(converted_claim_creation_time)
    end
  end

  describe "#assign_informal_conference" do
    subject { builder.send(:assign_informal_conference) }
    it "assigns claim_review's informal_conference to decision_reciew_created.informal_conference_requested" do
      expect(subject).to eq(decision_review_model.informal_conference_requested)
    end
  end

  describe "#assign_same_office" do
    subject { builder.send(:assign_same_office) }
    it "assigns claim_review's same_office to decision_reciew_created.same_station_review_requested" do
      expect(subject).to eq(decision_review_model.same_station_review_requested)
    end
  end

  describe "#assign_auto_remand" do
    subject { builder.send(:assign_auto_remand) }
    it "assigns claim_review's auto_remand to decision_reciew_created.auto_remand" do
      expect(subject).to eq(decision_review_model.auto_remand)
    end
  end
end
