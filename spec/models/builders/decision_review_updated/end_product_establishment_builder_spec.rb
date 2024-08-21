# frozen_string_literal: true

describe Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder do
    let(:decision_review_updated) { build(:decision_review_updated) }
    let(:builder) { described_class.new(decision_review_updated) }
  
    describe "#build" do
      subject { described_class.build(decision_review_updated) }
      it "returns an DecisionReviewUpdated::EndProductEstablishment object" do
        expect(subject).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
      end
    end
  
    describe "#initialize(decision_review_updated)" do
      let(:epe) { described_class.new(decision_review_updated).end_product_establishment }
  
      it "initializes a new EndProductEstablishmentBuilder instance" do
        expect(builder).to be_an_instance_of(described_class)
      end
  
      it "initializes a new DecisionReviewUpdated::EndProductEstablishment object" do
        expect(epe).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
      end
  
      it "assigns decision_review_updated to the DecisionReviewUpdated object passed in" do
        expect(builder.decision_review_updated).to be_an_instance_of(Transformers::DecisionReviewUpdated)
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
      let(:decision_review_updated) { build(:decision_review_updated) }
      let!(:builder) { described_class.new(decision_review_updated).assign_attributes }
  
      describe "#_assign_development_item_reference_id" do
        subject { builder.end_product_establishment.development_item_reference_id }
        it "should assign a development item referecne id to the epe instance" do
          expect(subject).to eq decision_review_updated.informal_conference_tracked_item_id
        end
      end
  
      describe "#_assign_reference_id" do
        it "should assign a reference id to the epe instance" do
          expect(builder.end_product_establishment.reference_id).to eq decision_review_updated.claim_id.to_s
        end
      end
    end
  end
  