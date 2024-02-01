# frozen_string_literal: true

describe Builders::EndProductEstablishmentBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns an EndProductEstablishment object" do
      expect(subject).to be_an_instance_of(EndProductEstablishment)
    end
  end

  describe "#initialize" do
    let(:epe) { described_class.new.end_product_establishment }

    it "initializes a new EndProductEstablishmentBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new EndProductEstablishment object" do
      expect(epe).to be_an_instance_of(EndProductEstablishment)
    end
  end

  describe "#assign_attributes(decision_review_created)" do
    it "calls private methods" do
      allow(builder).to receive(:calculate_benefit_type_code)
      allow(builder).to receive(:assign_claim_date)
      allow(builder).to receive(:assign_code)
      allow(builder).to receive(:assign_modifier)
      allow(builder).to receive(:calculate_limited_poa_access)
      allow(builder).to receive(:calculate_limited_poa_code)
      allow(builder).to receive(:calculate_committed_at)
      allow(builder).to receive(:calculate_established_at)
      allow(builder).to receive(:calculate_last_synced_at)
      allow(builder).to receive(:assign_synced_status)
      allow(builder).to receive(:assign_development_item_reference_id)
      allow(builder).to receive(:assign_reference_id)

      builder.assign_attributes(decision_review_created)

      expect(builder).to have_received(:calculate_benefit_type_code).with(decision_review_created)
      expect(builder).to have_received(:assign_claim_date).with(decision_review_created)
      expect(builder).to have_received(:assign_code).with(decision_review_created)
      expect(builder).to have_received(:assign_modifier).with(decision_review_created)
      expect(builder).to have_received(:calculate_limited_poa_access).with(decision_review_created)
      expect(builder).to have_received(:calculate_limited_poa_code).with(decision_review_created)
      expect(builder).to have_received(:calculate_committed_at).with(decision_review_created)
      expect(builder).to have_received(:calculate_established_at).with(decision_review_created)
      expect(builder).to have_received(:calculate_last_synced_at).with(decision_review_created)
      expect(builder).to have_received(:assign_synced_status).with(decision_review_created)
      expect(builder).to have_received(:assign_development_item_reference_id).with(decision_review_created)
      expect(builder).to have_received(:assign_reference_id).with(decision_review_created)
    end
  end
end
