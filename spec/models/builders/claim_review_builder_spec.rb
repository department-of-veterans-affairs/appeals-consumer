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
      expect(builder).to receive(:assign_legacy_opt_in_approved)
      expect(builder).to receive(:calculate_veteran_is_not_claimant)
      expect(builder).to receive(:calculate_establishment_attempted_at)
      expect(builder).to receive(:calculate_establishment_last_submitted_at)
      expect(builder).to receive(:calculate_establishment_processed_at)
      expect(builder).to receive(:calculate_establishment_submitted_at)
      expect(builder).to receive(:assign_informal_conference)
      expect(builder).to receive(:assign_same_office)

      builder.assign_attributes
    end
  end
end
