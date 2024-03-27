# frozen_string_literal: true

# Dummy class to include the module
class DummyClass
  include ModelBuilder
  attr_accessor :decision_review_created, :issue, :bis_synced_at
end

describe ModelBuilder do
  let(:dummy) { DummyClass.new }
  let(:file_number) { "123456789" }
  let(:claim_id) { "987654321" }
  let(:bis_record) { { ptcpnt_id: "12345" } }
  let(:limited_poa) { { claim_id => "POA info" } }
  let(:claim_received_date) { "2023-08-25" }
  let(:claim_creation_time) { Time.now.utc.to_s }
  let(:intake_creation_time) { Time.now.utc.to_s }

  before do
    @decision_review_created_double = instance_double(
      "Transformers::DecisionReviewCreated",
      file_number: file_number,
      claim_id: claim_id,
      veteran_participant_id: "123456789",
      claim_received_date: claim_received_date,
      claim_creation_time: claim_creation_time,
      intake_creation_time: intake_creation_time
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

  describe "#fetch_rating_profile" do
    context "when decision_review_created and issue are both present" do
      let(:rating_profile_date) { "2017-02-07T07:21:24+00:00" }
      let(:bis_record) do
        {
          associated_claims: [
            { clm_id: "abc123", bnft_clm_tc: "040SCR" },
            { clm_id: "dcf345", bnft_clm_tc: "154IVMC9PMC" }
          ]
        }
      end

      before do
        @issue_double = instance_double(
          "DecisionReviewIssue",
          prior_decision_rating_profile_date: rating_profile_date
        )
        dummy.issue = @issue_double
      end

      it "fetches the BIS rating profile record successfully" do
        allow(BISService).to receive(:new).and_return(double("BISService", fetch_rating_profile: bis_record))

        expect(dummy.fetch_rating_profile).to eq(bis_record)
      end

      it "raises an error if the BIS record is nil" do
        allow(BISService).to receive(:new).and_return(double("BISService", fetch_rating_profile: nil))

        expect { dummy.fetch_rating_profile }.to raise_error(AppealsConsumer::Error::BisRatingProfileNotFound)
      end

      it "raises an error if the BIS record is empty" do
        allow(BISService).to receive(:new).and_return(double("BISService", fetch_rating_profile: {}))

        expect { dummy.fetch_rating_profile }.to raise_error(AppealsConsumer::Error::BisRatingProfileNotFound)
      end
    end

    context "when decision_review_created or issue is not present" do
      context "when decision_review_created is not present" do
        it "returns nil" do
          dummy.decision_review_created = nil
          expect(dummy.fetch_rating_profile).to be_nil
        end
      end

      context "when issue is not present" do
        it "returns nil" do
          dummy.issue = nil
          expect(dummy.fetch_rating_profile).to be_nil
        end
      end
    end
  end

  describe "#convert_to_date_logical_type(value)" do
    context "when the value is nil" do
      before do
        @decision_review_created_double = instance_double(
          "Transformers::DecisionReviewCreated",
          file_number: file_number,
          claim_id: claim_id,
          claim_received_date: nil,
          claim_creation_time: claim_creation_time,
          intake_creation_time: intake_creation_time
        )
        dummy.decision_review_created = @decision_review_created_double
      end

      it "returns nil" do
        expect(dummy.convert_to_date_logical_type(dummy.decision_review_created.claim_received_date)).to be_nil
      end
    end

    context "when the value is not nil" do
      it "returns the value converted to date logical type" do
        claim_received_date = dummy.decision_review_created.claim_received_date
        expect(dummy.convert_to_date_logical_type(claim_received_date).class).to eq(Integer)
      end
    end
  end

  describe "#convert_to_timestamp_ms(value)" do
    context "when the value is nil" do
      before do
        @decision_review_created_double = instance_double(
          "Transformers::DecisionReviewCreated",
          file_number: file_number,
          claim_id: claim_id,
          claim_received_date: claim_received_date,
          claim_creation_time: claim_creation_time,
          intake_creation_time: nil
        )
        dummy.decision_review_created = @decision_review_created_double
      end

      it "returns nil" do
        expect(dummy.convert_to_timestamp_ms(dummy.decision_review_created.intake_creation_time)).to be_nil
      end
    end

    context "when the value is not nil" do
      it "returns the value converted to timestamp milliseconds" do
        expect(dummy.convert_to_timestamp_ms(dummy.decision_review_created.intake_creation_time).class).to eq(Integer)
      end
    end
  end

  describe "#claim_creation_time_converted_to_timestamp_ms" do
    context "when the decision_review_created is nil" do
      it "returns nil" do
        dummy.decision_review_created = nil
        expect(dummy.claim_creation_time_converted_to_timestamp_ms).to be_nil
      end
    end

    context "when decision_review_created_is_not_nil" do
      context "when claim_creation_time is nil" do
        before do
          @decision_review_created_double = instance_double(
            "Transformers::DecisionReviewCreated",
            file_number: file_number,
            claim_id: claim_id,
            claim_received_date: claim_received_date,
            claim_creation_time: nil,
            intake_creation_time: intake_creation_time
          )
          dummy.decision_review_created = @decision_review_created_double
        end

        it "returns nil" do
          expect(dummy.claim_creation_time_converted_to_timestamp_ms).to be_nil
        end
      end

      context "when claim_creation_time is not nil" do
        it "returns claim_creation_time converted to timestamp ms" do
          expect(dummy.claim_creation_time_converted_to_timestamp_ms).not_to be_nil
        end
      end
    end
  end
end
