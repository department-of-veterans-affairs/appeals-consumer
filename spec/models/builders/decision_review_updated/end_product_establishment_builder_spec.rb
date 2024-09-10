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
      expect(builder).to receive(:assign_development_item_reference_id)
      expect(builder).to receive(:assign_reference_id)
      expect(builder).to receive(:calculate_synced_status)
      expect(builder).to receive(:calculate_last_synced_at)

      builder.assign_attributes
    end
  end

  describe "private methods" do
    let(:builder) { described_class.new(decision_review_updated_model).assign_attributes }
    let(:epe) { builder.end_product_establishment }

    describe "#assign_development_item_reference_id" do
      it "assigns a development_item_reference_id to the epe" do
        expect(epe.development_item_reference_id).to eq decision_review_updated_model.informal_conference_tracked_item_id
      end
    end

    describe "#assign_reference_id" do
      it "assigns a reference_id to the epe" do
        expect(epe.reference_id).to eq decision_review_updated_model.claim_id.to_s
      end
    end

    describe "#calculate_synced_status" do
      context "decision_review_model has 'Open' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Open"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('PEND')
        end
      end

      context "decision_review_model has 'Ready to Work' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Ready to Work"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RW')
        end
      end

      context "decision_review_model has 'Ready for Decision' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Ready for Decision"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RFD')
        end
      end

      context "decision_review_model has 'Secondary Ready for Decision' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Secondary Ready for Decision"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('SRFD')
        end
      end

      context "decision_review_model has 'Rating Correction' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Rating Correction"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RC')
        end
      end

      context "decision_review_model has 'Rating Incomplete' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Rating Incomplete"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RI')
        end
      end

      context "decision_review_model has 'Rating Decision Complete' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Rating Decision Complete"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RDC')
        end
      end

      context "decision_review_model has 'Returned by Other User' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Returned by Other User"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('RETOTH')
        end
      end

      context "decision_review_model has 'Self Returned' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Self Returned"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('SELFRET')
        end
      end

      context "decision_review_model has 'Pending Authorization' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Pending Authorization"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('PENDAUTH')
        end
      end

      context "decision_review_model has 'Pending Concur' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Pending Concur"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('PENDCONC')
        end
      end

      context "decision_review_model has 'Authorized' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Authorized"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('AUTH')
        end
      end

      context "decision_review_model has 'Cancelled' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Cancelled"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('CAN')
        end
      end

      context "decision_review_model has 'Closed' for claim_lifecycle_status" do
        before do
          message_payload["claim_lifecycle_status"] = "Closed"
        end

        it 'assigns a PEND synced_status to the epe' do
          expect(epe.synced_status).to eq('CLOSED')
        end
      end
    end

    describe"#calculate_last_synced_at" do
      let(:claim_update_time_converted_to_timestamp) { builder.claim_creation_time_converted_to_timestamp_ms }
      
      it 'assigns a last_synced_at to the epe' do
        expect(epe.last_synced_at). to eq claim_update_time_converted_to_timestamp
      end
    end
  end
end
