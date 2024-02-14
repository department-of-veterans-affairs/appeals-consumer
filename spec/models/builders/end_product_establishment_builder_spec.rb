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
      expect(builder).to receive(:assign_committed_at)
      expect(builder).to receive(:assign_established_at)
      expect(builder).to receive(:assign_last_synced_at)
      expect(builder).to receive(:assign_synced_status)
      expect(builder).to receive(:assign_development_item_reference_id)
      expect(builder).to receive(:assign_reference_id)

      builder.assign_attributes
    end
  end

  describe "private methods" do
    let(:decision_review_created) { build(:decision_review_created) }
    let!(:builder) { described_class.new(decision_review_created).assign_attributes }

    describe "#_calculate_benefit_type_code" do
      it "should calculate benefit type code" do
      end
    end

    describe "#_assign_claim_date" do
      it "should assign a claim date to the epe instance" do
        expect(builder.end_product_establishment.claim_date).to eq decision_review_created.claim_received_date
      end
    end

    describe "#_assign_code" do
      it "should assign a code to the epe instance" do
        expect(builder.end_product_establishment.code).to eq decision_review_created.ep_code
      end
    end

    describe "#_assign_modifier" do
      it "should assign a modifier to the epe instance" do
        expect(builder.end_product_establishment.modifier).to eq decision_review_created.modifier
      end
    end

    describe "#_assign_payee_code" do
      it "should assign a payee code to the epe instance" do
        expect(builder.end_product_establishment.payee_code).to eq decision_review_created.payee_code
      end
    end

    describe "#_calculate_limited_poa_access" do
      it "should calculate the limited poa access and assign to the epe instance" do
      end
    end

    describe "#_calculate_limited_poa_code" do
      it "should calculate limited poa code and assign to the epe instance" do
      end
    end

    describe "#_assign_committed_at" do
      it "should assign a committed at to the epe instance" do
        expect(builder.end_product_establishment.committed_at).to eq decision_review_created.claim_creation_time
      end
    end

    describe "#_assign_established_at" do
      it "should assign an established at to the epe instance" do
        expect(builder.end_product_establishment.established_at).to eq decision_review_created.claim_creation_time
      end
    end

    describe "#_assign_last_synced_at" do
      it "should assign a last synced at to the epe instance" do
        expect(builder.end_product_establishment.last_synced_at).to eq decision_review_created.claim_creation_time
      end
    end

    describe "#_assign_synced_status" do
      it "should assign a synced status to the epe instance" do
        expect(builder.end_product_establishment.synced_status).to eq decision_review_created.claim_lifecycle_status
      end
    end

    describe "#_assign_development_item_reference_id" do
      it "should assign a development item referecne id to the epe instance" do
      end
    end

    describe "#_assign_reference_id" do
      it "should assign a reference id to the epe instance" do
        expect(builder.end_product_establishment.reference_id).to eq decision_review_created.claim_id
      end
    end
  end
end
