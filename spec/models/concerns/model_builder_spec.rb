# frozen_string_literal: true

# Dummy class to include the module
class DummyClass
  include ModelBuilder
  attr_accessor :decision_review_created, :bis_synced_at
end

describe ModelBuilder do
  let(:dummy) { DummyClass.new }
  let(:file_number) { "123456789" }
  let(:claim_id) { "987654321" }
  let(:bis_record) { { ptcpnt_id: "12345" } }
  let(:limited_poa) { { claim_id => "POA info" } }

  before do
    @decision_review_created_double = instance_double(
      "DecisionReviewCreate",
      file_number: file_number,
      claim_id: claim_id
    )
    dummy.decision_review_created = @decision_review_created_double
  end

  describe "#fetch_veteran_bis_record" do
    context "when decision_review_created is present" do
      it "fetches the veteran BIS record successfully" do
        allow(BISService).to receive(:new).and_return(double("BISService", fetch_veteran_info: bis_record))

        expect(dummy.fetch_veteran_bis_record).to eq(bis_record)
        expect(dummy.bis_synced_at).not_to be_nil
      end

      it "raises an error if the BIS record is nil or missing participant ID" do
        allow(BISService).to receive(:new).and_return(double("BISService", fetch_veteran_info: nil))

        expect { dummy.fetch_veteran_bis_record }.to raise_error(AppealsConsumer::Error::BisVeteranNotFound)
      end
    end
  end

  describe "#fetch_limited_poa" do
    context "when decision_review_created is present" do
      it "fetches the limited POA successfully" do
        allow(BISService).to receive(:new).and_return(double(
                                                        "BISService",
                                                        fetch_limited_poas_by_claim_ids: limited_poa
                                                      ))

        expect(dummy.fetch_limited_poa).to eq("POA info")
      end

      it "returns nil if the limited POA is not found" do
        allow(BISService).to receive(:new).and_return(double(
                                                        "BISService",
                                                        fetch_limited_poas_by_claim_ids: {}
                                                      ))

        expect(dummy.fetch_limited_poa).to be_nil
      end
    end

    context "when decision_review_created is nil" do
      it "returns nil" do
        dummy.decision_review_created = nil
        expect(dummy.fetch_limited_poa).to be_nil
      end
    end
  end
end
