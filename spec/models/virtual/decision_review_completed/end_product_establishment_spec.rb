# frozen_string_literal: true

require "shared_context/decision_review_completed_context"

describe DecisionReviewCompleted::EndProductEstablishment do
  include_context "decision_review_completed_context"

  let(:event_id) { 98_918 }
  let(:decision_review_completed_model) { Transformers::DecisionReviewCompleted.new(event_id, message_payload) }
  let(:end_product_establishment) do
    Builders::DecisionReviewCompleted::EndProductEstablishmentBuilder.build(decision_review_completed_model)
  end

  it "allows reader and writer access for attributes" do
    expect(end_product_establishment).to respond_to(:code)
    expect(end_product_establishment).to respond_to(:development_item_reference_id)
    expect(end_product_establishment).to respond_to(:reference_id)
    expect(end_product_establishment).to respond_to(:last_synced_at)
    expect(end_product_establishment).to respond_to(:synced_status)
  end

  it "assigns attributes appropriately" do
    expect(end_product_establishment.development_item_reference_id)
      .to eq(decision_review_completed_model.informal_conference_tracked_item_id)
    expect(end_product_establishment.reference_id).to eq(decision_review_completed_model.claim_id.to_s)
    expect(end_product_establishment.code).to eq(decision_review_completed_model.ep_code)
    expect(end_product_establishment.synced_status).to eq("CLR")
    expect(end_product_establishment.last_synced_at).not_to be_nil
  end
end
