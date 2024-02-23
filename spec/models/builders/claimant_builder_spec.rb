# frozen_string_literal: true

describe Builders::ClaimantBuilder do
  let(:decision_review_created) do
    build(:decision_review_created, payee_code: payee_code, claimant_participant_id: "5382910292")
  end
  let(:builder) { described_class.new(decision_review_created) }
  let(:claimant) { described_class.build(decision_review_created) }
  let(:payee_code) { "00" }

  describe "#build" do
    it "returns a Claimant object" do
      expect(claimant).to be_an_instance_of(Claimant)
    end
  end

  describe "initialization" do
    it "assigns @#decision_review_created and fetches bis record" do
      expect(builder.decision_review_created).to eq(decision_review_created)
      expect(builder.bis_record).not_to be_nil
    end
  end

  describe "#assign_attributes" do
    let(:bis_record) { Fakes::BISService.new.fetch_person_info(decision_review_created.claimant_participant_id) }
    before do
      allow_any_instance_of(BISService)
        .to receive(:fetch_person_info)
        .and_return(Fakes::BISService.new.fetch_person_info(decision_review_created.claimant_participant_id))
    end

    it "correctly assigns attribbutes from decision_review_created and bis_record" do
      expect(claimant.payee_code).to eq(decision_review_created.payee_code)
      expect(claimant.participant_id).to eq(decision_review_created.claimant_participant_id)
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

  describe "error handling for fetching BIS record" do
    context "when the BIS record is not found" do
      before do
        allow_any_instance_of(BISService).to receive(:fetch_person_info).and_return({})
      end

      it "raises an error" do
        expect { claimant }.to raise_error(AppealsConsumer::Error::BisClaimantNotFound)
      end
    end
  end
end
