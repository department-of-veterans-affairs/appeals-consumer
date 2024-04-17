# frozen_string_literal: true

describe Builders::DecisionReviewCreated::EndProductEstablishmentBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let!(:event) { create(:decision_review_created_event, message_payload: decision_review_created.to_json) }
  let!(:event_id) { event.id }
  let(:ready_to_work_status) { "RW" }
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
    decision_review_created.instance_variable_set(:@event_id, event_id)
    Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
  end

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns an DecisionReviewCreated::EndProductEstablishment object" do
      expect(subject).to be_an_instance_of(DecisionReviewCreated::EndProductEstablishment)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:epe) { described_class.new(decision_review_created).end_product_establishment }

    it "initializes a new EndProductEstablishmentBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new DecisionReviewCreated::EndProductEstablishment object" do
      expect(epe).to be_an_instance_of(DecisionReviewCreated::EndProductEstablishment)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(Transformers::DecisionReviewCreated)
    end

    context "when the BIS record is not found" do
      let(:msg) do
        "BIS Veteran: Veteran record not found for DecisionReviewCreated file_number:"\
       " #{decision_review_created.file_number}"
      end
      let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }
      subject { described_class.build(decision_review_created) }

      before do
        decision_review_created.instance_variable_set(:@event_id, event_id)
        allow_any_instance_of(BISService).to receive(:fetch_veteran_info).and_return({ ptcpnt_id: nil })
        allow(Rails.logger).to receive(:info)
      end

      it "logs message" do
        expect(Rails.logger).to receive(:info).with(/#{msg}/)
        subject
      end

      context "when there is already a message in the event_audit's notes column" do
        let!(:event_audit_with_note) do
          create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note.")
        end

        it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
          subject
          expect(event_audit_with_note.reload.notes)
            .to eq("Note #{Time.zone.now}: Test note. - Note #{Time.zone.now}: #{msg}")
        end
      end

      context "when there isn't a message in the event_audit's notes column" do
        it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
          subject
          expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
        end
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
      expect(builder).to receive(:calculate_synced_status)
      expect(builder).to receive(:assign_development_item_reference_id)
      expect(builder).to receive(:assign_reference_id)

      builder.assign_attributes
    end
  end

  describe "private methods" do
    let(:decision_review_created) { build(:decision_review_created) }
    let!(:builder) { described_class.new(decision_review_created).assign_attributes }

    describe "#_calculate_benefit_type_code" do
      before do
        BISService.clean!
      end

      context "@veteran_bis_record is nil" do
        let(:veteran_bis_record) { nil }

        before do
          Fakes::VeteranStore.new
            .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
        end

        it "sets benefit_type_code to nil" do
          expect(builder.end_product_establishment.benefit_type_code).to eq nil
        end
      end

      context "@veteran_bis_record is not nil" do
        context "date_of_death is valid key" do
          context "date_of_death has not-nil value" do
            let(:veteran_bis_record) do
              {
                file_number: decision_review_created.file_number,
                date_of_death: "12/31/2019"
              }
            end

            before do
              Fakes::VeteranStore.new
                .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
            end

            it "should set benefit_type_code to '2'" do
              expect(builder.end_product_establishment.benefit_type_code).to eq("2")
            end
          end

          context "date_of_death has nil value" do
            let(:veteran_bis_record) do
              {
                file_number: decision_review_created.file_number,
                date_of_death: nil
              }
            end

            before do
              Fakes::VeteranStore.new
                .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
            end

            it "should set benefit_type_code to '1'" do
              expect(builder.end_product_establishment.benefit_type_code).to eq("1")
            end
          end
        end

        context "date_of_death is not valid key" do
          let(:veteran_bis_record) do
            {
              file_number: decision_review_created.file_number
            }
          end

          before do
            Fakes::VeteranStore.new
              .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
          end

          it "sets benefit_type_code to nil" do
            expect(builder.end_product_establishment.benefit_type_code).to eq(nil)
          end
        end
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

    describe "#_calculate_synced_status" do
      it "should assign a synced status to the epe instance" do
        expect(builder.end_product_establishment.synced_status).to eq(ready_to_work_status)
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

  describe "#_determine_date_of_death" do
    subject { builder.send(:determine_date_of_death) }
    before do
      BISService.clean!
    end

    context "@veteran_bis_record is nil" do
      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "@veteran_bis_record doesn't have date_of_death key" do
      let(:veteran_bis_record) do
        {
          pcpnt_id: nil
        }
      end

      before do
        Fakes::VeteranStore.new
          .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "date_of_death is valid key" do
      context "date_of_death has not-nil value" do
        let(:veteran_bis_record) do
          {
            file_number: decision_review_created.file_number,
            date_of_death: "12/31/2019"
          }
        end

        before do
          Fakes::VeteranStore.new
            .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
        end

        it "returns '2'" do
          expect(subject).to eq("2")
        end
      end

      context "date_of_death has nil value" do
        let(:veteran_bis_record) do
          {
            file_number: decision_review_created.file_number,
            date_of_death: nil
          }
        end

        before do
          Fakes::VeteranStore.new
            .store_veteran_record(decision_review_created.file_number, veteran_bis_record)
        end

        it "returns '1'" do
          expect(subject).to eq("1")
        end
      end
    end
  end
end
