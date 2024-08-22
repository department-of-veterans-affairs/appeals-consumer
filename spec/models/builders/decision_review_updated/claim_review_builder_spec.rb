# frozen_string_literal: true

describe Builders::DecisionReviewUpdated::ClaimReviewBuilder do
  let(:decision_review_updated) { build(:decision_review_updated) }
  let(:builder) { described_class.new(decision_review_updated) }

  describe "#build" do
    subject { described_class.build(decision_review_updated) }
    it "returns a DecisionReviewUpdated::ClaimReview object" do
      expect(subject).to be_an_instance_of(DecisionReviewUpdated::ClaimReview)
    end
  end

  describe "#initialize(decision_review_updated)" do
    let(:claim_review) { described_class.new(decision_review_updated).claim_review }

    it "initializes a new ClaimReviewBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new DecisionReviewUpdated::ClaimReview object" do
      expect(claim_review).to be_an_instance_of(DecisionReviewUpdated::ClaimReview)
    end

    it "assigns decision_review_updated to the DecisionReviewUpdated object passed in" do
      expect(builder.decision_review_updated).to be_an_instance_of(Transformers::DecisionReviewUpdated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:assign_informal_conference)
      expect(builder).to receive(:assign_same_office)
      expect(builder).to receive(:calculate_legacy_opt_in_approved)

      builder.assign_attributes
    end
  end

  describe "#assign_informal_conference" do
    subject { builder.send(:assign_informal_conference) }
    it "assigns claim_review's informal_conference to decision_review_updated.informal_conference_requested" do
      expect(subject).to eq(decision_review_updated.informal_conference_requested)
    end
  end

  describe "#assign_same_office" do
    subject { builder.send(:assign_same_office) }
    it "assigns claim_review's same_office to decision_review_updated.same_station_review_requested" do
      expect(subject).to eq(decision_review_updated.same_station_review_requested)
    end
  end

  describe "#calculate_legacy_opt_in_approved" do
    subject { builder.send(:calculate_legacy_opt_in_approved) }

    context "when decision_review_updated contains a decision_review_issue with soc_opt_in: true" do
      let(:decision_review_updated) do
        build(:decision_review_updated, :ineligible_nonrating_hlr_pending_legacy_appeal)
      end

      it "assigns claim_review's legacy_opt_in_approved to true" do
        expect(subject).to eq(true)
      end
    end

    context "when decision_review_updated DOES NOT contain a decision_review_issue with soc_opt_in: true" do
      it "assigns claim_review's legacy_opt_in_approved to false" do
        expect(subject).to eq(false)
      end
    end
  end
end
