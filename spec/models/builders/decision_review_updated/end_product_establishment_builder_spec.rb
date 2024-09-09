# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder do
  include_context "decision_review_updated_context"

  let(:event_id) { 71_641 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:builder) { described_class.new(decision_review_updated_model) }

  describe "#build" do
    subject { described_class.build(decision_review_updated_model) }
    it "returns an DecisionReviewUpdated::EndProductEstablishment object" do
      expect(subject).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
    end
  end

  describe "#initialize(decision_review_updated)" do
    let(:epe) { described_class.new(decision_review_updated_model).end_product_establishment }

    it "initializes a new EndProductEstablishmentBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new DecisionReviewUpdated::EndProductEstablishment object" do
      expect(epe).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
    end

    it "assigns decision_review_updated to the DecisionReviewUpdated object passed in" do
      expect(builder.decision_review_model).to be_an_instance_of(Transformers::DecisionReviewUpdated)
    end
  end

  describe "#assign_attributes" do
    let(:builder) { described_class.new(decision_review_updated_model).assign_attributes }
    let(:epe) { builder.end_product_establishment }
    let(:claim_update_time_converted_to_timestamp) { builder.claim_creation_time_converted_to_timestamp_ms }

    it "assigns development_item_reference_id" do
      expect(epe.development_item_reference_id).to eq decision_review_updated_model.informal_conference_tracked_item_id
    end

    it "assigns reference_id" do
      expect(epe.reference_id).to eq decision_review_updated_model.claim_id.to_s
    end

    it 'calculates synced_status' do
      expect(epe.synced_status).to eq('RFD')
    end

    it 'calculates last_synced_at' do
      expect(epe.last_synced_at). to eq claim_update_time_converted_to_timestamp
    end
  end
end
