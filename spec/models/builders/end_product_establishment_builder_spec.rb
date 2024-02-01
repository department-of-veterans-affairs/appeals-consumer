# frozen_string_literal: true

describe Builders::EndProductEstablishmentBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns an EndProductEstablishment object" do
      expect(subject).to be_an_instance_of(EndProductEstablishment)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:epe) { described_class.new(decision_review_created).end_product_establishment }

    it "initializes a new EndProductEstablishmentBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new EndProductEstablishment object" do
      expect(epe).to be_an_instance_of(EndProductEstablishment)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:calculate_benefit_type_code)
      expect(builder).to receive(:assign_claim_date)
      expect(builder).to receive(:assign_code)
      expect(builder).to receive(:assign_modifier)
      expect(builder).to receive(:calculate_limited_poa_access)
      expect(builder).to receive(:calculate_limited_poa_code)
      expect(builder).to receive(:calculate_committed_at)
      expect(builder).to receive(:calculate_established_at)
      expect(builder).to receive(:calculate_last_synced_at)
      expect(builder).to receive(:assign_synced_status)
      expect(builder).to receive(:assign_development_item_reference_id)
      expect(builder).to receive(:assign_reference_id)

      builder.assign_attributes
    end
  end
end
