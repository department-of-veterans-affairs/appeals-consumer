# frozen_string_literal: true

describe Builders::BaseClaimantBuilder do
  let(:decision_review_model) do
    build(:decision_review_created, payee_code: payee_code, claimant_participant_id: "5382910292")
  end
  let!(:event) { create(:decision_review_created_event, message_payload: decision_review_model.to_json) }
  let!(:event_id) { event.id }
  let(:builder) { described_class.new(decision_review_model) }
  let(:claimant) { described_class.build(decision_review_model) }
  let(:payee_code) { "00" }

  before do
    decision_review_model.instance_variable_set(:@event_id, event_id)
  end

  describe "#build" do
    it "returns a BaseClaimant object" do
      expect(claimant).to be_an_instance_of(BaseClaimant)
    end
  end

  describe "initialization" do
    it "assigns @#decision_review_created and fetches bis record" do
      expect(builder.decision_review_model).to eq(decision_review_model)
      expect(builder.bis_record).not_to be_nil
    end
  end

  describe "#assign_attributes" do
    let(:bis_record) { Fakes::BISService.new.fetch_person_info(decision_review_model.claimant_participant_id) }
    before do
      allow_any_instance_of(BISService)
        .to receive(:fetch_person_info)
        .and_return(Fakes::BISService.new.fetch_person_info(decision_review_model.claimant_participant_id))
    end

    it "correctly assigns attribbutes from decision_review_model and bis_record" do
      expect(claimant.payee_code).to eq(decision_review_model.payee_code)
      expect(claimant.participant_id).to eq(decision_review_model.claimant_participant_id)
      expect(claimant.name_suffix).to eq(bis_record[:name_suffix])
      expect(claimant.ssn).to eq(bis_record[:ssn])
      expect(claimant.date_of_birth).to eq(bis_record[:birth_date].to_i * 1000)
      expect(claimant.first_name).to eq(bis_record[:first_name])
      expect(claimant.middle_name).to eq(bis_record[:middle_name])
      expect(claimant.last_name).to eq(bis_record[:last_name])
      expect(claimant.email).to eq(bis_record[:email_address])
    end
  end

  describe "determining claimant type" do
    subject { claimant.type }

    context "when payee code is '00'" do
      let(:payee_code) { "00" }
      it { is_expected.to eq("VeteranClaimant") }
    end

    context "when payee code is not '00'" do
      let(:payee_code) { "01" }
      it { is_expected.to eq("DependentClaimant") }
    end
  end

  describe "fetching BIS record" do
    context "when the BIS record is not found" do
      let(:msg) do
        "BIS Person: Person record not found for DecisionReviewCreated claimant_participant_id:"\
        " #{decision_review_model.claimant_participant_id}"
      end
      let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

      before do
        allow_any_instance_of(BISService).to receive(:fetch_person_info).and_return({})
        allow(Rails.logger).to receive(:info)
      end

      it "logs message" do
        expect(Rails.logger).to receive(:info).with(/#{msg}/)
        claimant
      end

      it "sets BIS fields to nil" do
        expect(claimant.name_suffix).to eq nil
        expect(claimant.ssn).to eq nil
        expect(claimant.date_of_birth).to eq nil
        expect(claimant.first_name).to eq nil
        expect(claimant.middle_name).to eq nil
        expect(claimant.last_name).to eq nil
        expect(claimant.email).to eq nil
      end

      context "when there is already a message in the event_audit's notes column" do
        let!(:event_audit_with_note) do
          create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
        end

        it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
          claimant
          expect(event_audit_with_note.reload.notes)
            .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{msg}")
        end
      end

      context "when there isn't a message in the event_audit's notes column" do
        it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
          claimant
          expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
        end
      end
    end
  end
end
