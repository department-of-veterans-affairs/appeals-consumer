# frozen_string_literal: true

describe Builders::ClaimReviewBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a ClaimReview object" do
      expect(subject).to be_an_instance_of(ClaimReview)
    end
  end

  describe "#initialize" do
    let(:claim_review) { described_class.new.claim_review }

    it "initializes a new ClaimReviewBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new ClaimReview object" do
      expect(claim_review).to be_an_instance_of(ClaimReview)
    end
  end

  describe "#assign_attributes(decision_review_created)" do
    it "calls private methods" do
      allow(builder).to receive(:calculate_benefit_type)
      allow(builder).to receive(:assign_filed_by_va_gov)
      allow(builder).to receive(:assign_receipt_date)
      allow(builder).to receive(:assign_legacy_opt_in_approved)
      allow(builder).to receive(:calculate_veteran_is_not_claimant)
      allow(builder).to receive(:calculate_establishment_attempted_at)
      allow(builder).to receive(:calculate_establishment_last_submitted_at)
      allow(builder).to receive(:calculate_establishment_processed_at)
      allow(builder).to receive(:calculate_establishment_submitted_at)
      allow(builder).to receive(:assign_informal_conference)
      allow(builder).to receive(:assign_same_office)

      builder.assign_attributes(decision_review_created)

      expect(builder).to have_received(:calculate_benefit_type).with(decision_review_created)
      expect(builder).to have_received(:assign_filed_by_va_gov).with(decision_review_created)
      expect(builder).to have_received(:assign_receipt_date).with(decision_review_created)
      expect(builder).to have_received(:assign_legacy_opt_in_approved).with(decision_review_created)
      expect(builder).to have_received(:calculate_veteran_is_not_claimant).with(decision_review_created)
      expect(builder).to have_received(:calculate_establishment_attempted_at).with(decision_review_created)
      expect(builder).to have_received(:calculate_establishment_last_submitted_at).with(decision_review_created)
      expect(builder).to have_received(:calculate_establishment_processed_at).with(decision_review_created)
      expect(builder).to have_received(:calculate_establishment_submitted_at).with(decision_review_created)
      expect(builder).to have_received(:assign_informal_conference).with(decision_review_created)
      expect(builder).to have_received(:assign_same_office).with(decision_review_created)
    end
  end
end
