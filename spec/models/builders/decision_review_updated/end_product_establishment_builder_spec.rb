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
    it "calls private methods" do
      expect(builder).to receive(:assign_decision_review_updated_development_item_reference_id)
      expect(builder).to receive(:assign_decision_review_updated_reference_id)

      builder.assign_attributes
    end
  end

  describe "private methods" do
    let!(:builder) { described_class.new(decision_review_updated_model).assign_attributes }

    describe "#assign_decision_review_updated_development_item_reference_id" do
      subject { builder.end_product_establishment.development_item_reference_id }
      it "should assign a development item referecne id to the EndProductEstablishment instance" do
        expect(subject).to eq decision_review_updated_model.informal_conference_tracked_item_id
      end
    end

    describe "#assign_decision_review_updated_reference_id" do
      it "should assign a reference id to the EndProductEstablishment instance" do
        expect(builder.end_product_establishment.reference_id).to eq decision_review_updated_model.claim_id.to_s
      end
    end
  end
end
