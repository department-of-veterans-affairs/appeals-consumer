# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe DecisionReviewUpdated::EndProductEstablishment do
  include_context "decision_review_updated_context"

  let(:event_id) { 98_918 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:end_product_establishment) do
    Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder.build(decision_review_updated_model)
  end

  it "allows reader and writer access for attributes" do
    expect(end_product_establishment.development_item_reference_id).to eq("1")
    expect(end_product_establishment.reference_id).to eq(decision_review_updated_model.claim_id.to_s)
  end
end
