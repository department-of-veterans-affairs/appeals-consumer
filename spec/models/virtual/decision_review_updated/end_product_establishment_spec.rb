# frozen_string_literal: true

describe DecisionReviewCreated::EndProductEstablishment do
    let(:decision_review_updated) { build(:decision_review_updated) }
    let(:end_product_establishment) { Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder.build(decision_review_updated) }
    let(:claim_id) { decision_review_updated.claim_id.to_s }
  
    it "allows reader and writer access for attributes" do
      expect(end_product_establishment.development_item_reference_id).to eq("1")
      expect(end_product_establishment.reference_id).to be_a(String)
      expect(end_product_establishment.reference_id.length).to eq(claim_id.length)
    end
  end