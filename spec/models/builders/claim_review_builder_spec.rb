# frozen_string_literal: true

describe Builders::ClaimReviewBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    subject { described_class.build(decision_review_created) }

    it "returns a ClaimReview object" do
      expect(subject).to be_an_instance_of(ClaimReview)
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:claim_review) { described_class.new.claim_review }

    it "initializes a new ClaimReviewBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new ClaimReview object" do
      expect(claim_review).to be_an_instance_of(ClaimReview)
    end
  end
end
