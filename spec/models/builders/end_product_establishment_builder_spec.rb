# frozen_string_literal: true

describe Builders::EndProductEstablishmentBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let(:veteran_bis_record) do
    {
      file_number: decision_review_created.file_number,
      ptcpnt_id: decision_review_created.veteran_participant_id,
      sex: "M",
      first_name: decision_review_created.veteran_first_name,
      middle_name: "Russell",
      last_name: decision_review_created.veteran_last_name,
      name_suffix: "II",
      ssn: "987654321",
      address_line1: "122 Mullberry St.",
      address_line2: "PO BOX 123",
      address_line3: "Daisies",
      city: "Orlando",
      state: "FL",
      country: "USA",
      date_of_birth: "12/21/1989",
      date_of_death: "12/31/2019",
      zip_code: "94117",
      military_post_office_type_code: nil,
      military_postal_type_code: nil,
      service: [{ branch_of_service: "army", pay_grade: "E4" }]
    }
  end
  let(:claim_creation_time_converted_to_timestamp) { builder.claim_creation_time_converted_to_timestamp_ms }

  before do
    Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
  end

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

    context "no bis_record or participant_id in fetch_veteran_info call" do
      let(:error) { AppealsConsumer::Error::BisVeteranNotFound }
      it "should throw error" do
        allow_any_instance_of(BISService).to receive(:fetch_veteran_info).and_return(nil)
        expect { described_class.new(decision_review_created) }.to raise_error(error)
      end
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:calculate_benefit_type_code)
      expect(builder).to receive(:calculate_claim_date)
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

  describe "private methods" do
    let(:decision_review_created) { build(:decision_review_created) }
    let!(:builder) { described_class.new(decision_review_created).assign_attributes }

    describe "#_calculate_benefit_type_code" do
      it "should calculate benefit type code" do
        expect(builder.end_product_establishment.benefit_type_code).to eq "2"
      end
    end

    describe "#_calculate_claim_date" do
      let(:converted_claim_date) do
        builder.convert_to_date_logical_type(decision_review_created.claim_received_date)
      end
      it "should assign a claim date to the epe instance" do
        expect(builder.end_product_establishment.claim_date).to eq converted_claim_date
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
      let(:decision_review_created) { build(:decision_review_created, claim_id: 1) }
      subject { builder.end_product_establishment.limited_poa_access }

      context "the limited_poa_access result returns 'Y'" do
        it "should calculate the limited poa access and assign to the epe instance" do
          expect(subject).to eq true
        end
      end

      context "the limited_poa_access result returns 'N'" do
        let(:decision_review_created) { build(:decision_review_created, claim_id: 2) }

        it "should calculate the limited poa access and assign to the epe instance" do
          expect(subject).to eq false
        end
      end

      context "the limited_poa_access result returns nil" do
        let(:decision_review_created) { build(:decision_review_created, claim_id: 0) }

        it "should calculate the limited poa access and assign to the epe instance" do
          expect(subject).to eq nil
        end
      end
    end

    describe "#_calculate_limited_poa_code" do
      subject { builder.end_product_establishment.limited_poa_code }
      it "should calculate limited poa code and assign to the epe instance" do
        expect(subject).to eq builder.instance_variable_get(:@limited_poa_hash)&.dig(:limited_poa_code)
      end
    end

    describe "#_calculate_committed_at" do
      it "should assign a committed at to the epe instance" do
        expect(builder.end_product_establishment.committed_at).to eq claim_creation_time_converted_to_timestamp
      end
    end

    describe "#_calculate_established_at" do
      it "should assign an established at to the epe instance" do
        expect(builder.end_product_establishment.established_at).to eq claim_creation_time_converted_to_timestamp
      end
    end

    describe "#_calculate_last_synced_at" do
      it "should assign a last synced at to the epe instance" do
        expect(builder.end_product_establishment.last_synced_at).to eq claim_creation_time_converted_to_timestamp
      end
    end

    describe "#_assign_synced_status" do
      it "should assign a synced status to the epe instance" do
        expect(builder.end_product_establishment.synced_status).to eq decision_review_created.claim_lifecycle_status
      end
    end

    describe "#_assign_development_item_reference_id" do
      subject { builder.end_product_establishment.development_item_reference_id }
      it "should assign a development item referecne id to the epe instance" do
        expect(subject).to eq decision_review_created.informal_conference_tracked_item_id
      end
    end

    describe "#_assign_reference_id" do
      it "should assign a reference id to the epe instance" do
        expect(builder.end_product_establishment.reference_id).to eq decision_review_created.claim_id.to_s
      end
    end
  end
end
