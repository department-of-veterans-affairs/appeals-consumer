# frozen_string_literal: true

# Dummy class to include the module
class DummyClass
  include DecisionReviewCreated::ModelBuilder
  attr_accessor :decision_review_created, :bis_synced_at, :earliest_issue_profile_date,
                :latest_issue_profile_date_plus_one_day
end

describe DecisionReviewCreated::ModelBuilder do
  let(:dummy) { DummyClass.new }
  let(:file_number) { "123456789" }
  let(:claim_id) { "987654321" }
  let(:bis_record) { { ptcpnt_id: "12345" } }
  let(:limited_poa) { { claim_id => "POA info" } }
  let(:claim_received_date) { "2023-08-25" }
  let(:claim_creation_time) { Time.now.utc.to_s }
  let(:intake_creation_time) { Time.now.utc.to_s }
  let!(:event) { create(:decision_review_created_event) }
  let!(:event_id) { event.id }

  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
    @decision_review_created_double = instance_double(
      "Transformers::DecisionReviewCreated",
      file_number: file_number,
      claim_id: claim_id,
      veteran_participant_id: "123456789",
      claimant_participant_id: "12345",
      claim_received_date: claim_received_date,
      claim_creation_time: claim_creation_time,
      intake_creation_time: intake_creation_time,
      event_id: event_id
    )
    dummy.decision_review_created = @decision_review_created_double
  end

  describe "#fetch_veteran_bis_record" do
    subject { dummy.fetch_veteran_bis_record }
    context "when decision_review_created is present" do
      context "when the BIS record is found" do
        it "fetches the veteran BIS record successfully" do
          allow(BISService).to receive(:new).and_return(double("BISService", fetch_veteran_info: bis_record))

          expect(subject).to eq(bis_record)
          expect(dummy.bis_synced_at).not_to be_nil
        end
      end

      context "when the BIS record is not found" do
        let(:msg) do
          "BIS Veteran: Veteran record not found for DecisionReviewCreated file_number:"\
          " #{dummy.decision_review_created.file_number}"
        end
        let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

        before do
          allow_any_instance_of(BISService).to receive(:fetch_veteran_info).and_return({ ptcpnt_id: nil })
          allow(Rails.logger).to receive(:info)
        end

        it "logs message" do
          expect(Rails.logger).to receive(:info).with(/#{msg}/)
          subject
        end

        context "when there is already a message in the event_audit's notes column" do
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
          end

          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{msg}")
          end
        end

        context "when there isn't a message in the event_audit's notes column" do
          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
          end
        end
      end

      context "an error is thrown" do
        let(:error) { AppealsConsumer::Error::BisVeteranError }
        let(:msg) do
          "Failed fetching Veteran info from"\
            " DecisionReviewCreated::ModelBuilder: #{timeout_msg}"
        end
        let(:timeout_msg) { "timeout" }

        before do
          bis_service_instance = instance_double(BISService)
          allow(BISService).to receive(:new).and_return(bis_service_instance)
          allow(bis_service_instance).to receive(:fetch_veteran_info).and_raise(StandardError, timeout_msg)
        end

        it "rescues the error and rethrows custom exception" do
          expect { subject }.to raise_error(error, msg)
        end
      end
    end
  end

  describe "#fetch_person_bis_record" do
    subject { dummy.fetch_person_bis_record }
    context "when decision_review_created is present" do
      context "when the BIS record is found" do
        it "fetches the veteran BIS record successfully" do
          allow(BISService).to receive(:new).and_return(double("BISService", fetch_person_info: bis_record))

          expect(subject).to eq(bis_record)
        end
      end

      context "when the BIS record is not found" do
        let(:msg) do
          "BIS Person: Person record not found for DecisionReviewCreated claimant_participant_id:"\
            " #{dummy.decision_review_created.claimant_participant_id}"
        end
        let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

        before do
          allow_any_instance_of(BISService).to receive(:fetch_person_info).and_return({})
          allow(Rails.logger).to receive(:info)
        end

        it "logs message" do
          expect(Rails.logger).to receive(:info).with(/#{msg}/)
          subject
        end

        context "when there is already a message in the event_audit's notes column" do
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
          end

          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{msg}")
          end
        end

        context "when there isn't a message in the event_audit's notes column" do
          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
          end
        end
      end

      context "an error is thrown" do
        let(:error) { AppealsConsumer::Error::BisPersonError }
        let(:msg) do
          "Failed fetching Person info from"\
            " DecisionReviewCreated::ModelBuilder: #{timeout_msg}"
        end
        let(:timeout_msg) { "timeout" }

        before do
          bis_service_instance = instance_double(BISService)
          allow(BISService).to receive(:new).and_return(bis_service_instance)
          allow(bis_service_instance).to receive(:fetch_person_info).and_raise(StandardError, timeout_msg)
        end

        it "rescues the error and rethrows custom exception" do
          expect { subject }.to raise_error(error, msg)
        end
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

      context "an error is thrown" do
        let(:error) { AppealsConsumer::Error::BisLimitedPoaError }
        let(:msg) do
          "Failed fetching Limited POA info from"\
            " DecisionReviewCreated::ModelBuilder: #{timeout_msg}"
        end
        let(:timeout_msg) { "timeout" }

        before do
          bis_service_instance = instance_double(BISService)
          allow(BISService).to receive(:new).and_return(bis_service_instance)
          allow(bis_service_instance).to receive(:fetch_limited_poas_by_claim_ids).and_raise(StandardError, timeout_msg)
        end

        it "rescues the error and rethrows custom exception" do
          expect { dummy.fetch_limited_poa }.to raise_error(error, msg)
        end
      end
    end

    context "when decision_review_created is nil" do
      it "returns nil" do
        dummy.decision_review_created = nil
        expect(dummy.fetch_limited_poa).to be_nil
      end
    end
  end

  describe "#fetch_bis_rating_profiles" do
    subject { dummy.fetch_bis_rating_profiles }

    context "when decision_review_created, earliest_issue_profile_date, and"\
      " latest_issue_profile_date_plus_one_day are all present" do
      let(:earliest_date) { "2017-02-07T07:21:24+00:00" }
      let(:latest_date) { "2017-02-10T07:21:24+00:00" }

      before do
        dummy.earliest_issue_profile_date = earliest_date.to_date
        dummy.latest_issue_profile_date_plus_one_day = latest_date.to_date + 1
      end

      context "response is successfully returned" do
        let(:bis_rating_profiles) do
          {
            rba_issue_list: {
              rba_issue: {
                rba_issue_id: "123456",
                prfil_date: Date.new(2017, 2, 7)
              }
            },
            rba_claim_list: {
              rba_claim: {
                bnft_clm_tc: "030HLRR",
                clm_id: "1002003",
                prfl_date: Date.new(2017, 2, 10)
              }
            },
            response: {
              response_text: "Success"
            }
          }
        end

        it "fetches the BIS rating profile record successfully" do
          allow(BISService).to receive(:new)
            .and_return(double("BISService", fetch_rating_profiles_in_range: bis_rating_profiles))
          expect(subject).to eq(bis_rating_profiles)
        end
      end

      context "when no records are found" do
        let(:msg) do
          "BIS Rating Profiles: Rating Profile info not found for DecisionReviewCreated veteran_participant_id"\
            " #{dummy.decision_review_created.veteran_participant_id} within the date range"\
            " #{dummy.earliest_issue_profile_date} - #{dummy.latest_issue_profile_date_plus_one_day}."
        end
        let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

        before do
          allow(BISService).to receive(:new)
            .and_return(
              double(
                "BISService",
                fetch_rating_profiles_in_range: { response: { response_text: "No Data Found" } }
              )
            )
          allow(Rails.logger).to receive(:info)
        end

        it "logs message" do
          expect(Rails.logger).to receive(:info).with(/#{msg}/)
          subject
        end

        context "when there is already a message in the event_audit's notes column" do
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
          end

          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{msg}")
          end
        end

        context "when there isn't a message in the event_audit's notes column" do
          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
          end
        end
      end

      context "an error is thrown" do
        let(:error) { AppealsConsumer::Error::BisRatingProfilesError }
        let(:msg) do
          "Failed fetching Rating Profiles info from"\
            " DecisionReviewCreated::ModelBuilder: #{timeout_msg}"
        end
        let(:timeout_msg) { "timeout" }

        before do
          bis_service_instance = instance_double(BISService)
          allow(BISService).to receive(:new).and_return(bis_service_instance)
          allow(bis_service_instance).to receive(:fetch_rating_profiles_in_range).and_raise(StandardError, timeout_msg)
        end

        it "rescues the error and rethrows custom exception" do
          expect { subject }.to raise_error(error, msg)
        end
      end
    end

    context "when decision_review_created, earliest_issue_profile_date, or latest_issue_profile_date_plus_one_day"\
      " is not present" do
      context "when decision_review_created is not present" do
        it "returns nil" do
          dummy.decision_review_created = nil
          expect(subject).to be_nil
        end
      end

      context "when earliest_issue_profile_date is not present" do
        it "returns nil" do
          dummy.earliest_issue_profile_date = nil
          expect(subject).to be_nil
        end
      end

      context "when latest_issue_profile_date_plus_one_day is not present" do
        it "returns nil" do
          dummy.latest_issue_profile_date_plus_one_day = nil
          expect(subject).to be_nil
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

  describe "#downcase_bis_rating_profiles_response_text" do
    context "when @bis_rating_profiles_record is nil" do
      it "returns nil" do
        expect(dummy.send(:downcase_bis_rating_profiles_response_text)).to eq(nil)
      end
    end

    context "when @bis_rating_profiles is not nil" do
      context ":response_text key exists" do
        let(:hash_with_response_text) do
          { response: { response_text: "No Data Found" } }
        end

        before do
          dummy.instance_variable_set(:@bis_rating_profiles_record, hash_with_response_text)
        end

        it "returns the value of :response_text and converts to downcase" do
          expect(dummy.send(:downcase_bis_rating_profiles_response_text)).to eq("no data found")
        end
      end

      context ":response_text key does not exist" do
        let(:hash_without_response_text) do
          { rba_claim_list: { rba_claim: {} } }
        end

        before do
          dummy.instance_variable_set(:@bis_rating_profiles_record, hash_without_response_text)
        end

        it "returns nil" do
          expect(dummy.send(:downcase_bis_rating_profiles_response_text)).to eq(nil)
        end
      end
    end
  end

  describe "#handle_response(msg)" do
    let(:msg) { "Test note" }
    let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

    it "logs the message" do
      allow(Rails.logger).to receive(:info)
      dummy.send(:handle_response, msg)
      expect(Rails.logger).to have_received(:info).with(/#{msg}/)
    end

    it "updates the last event's 'in_progress' event_audit note column with the message" do
      dummy.send(:handle_response, msg)
      expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: Test note")
    end
  end

  describe "#log_info(msg)" do
    let(:msg) { "Test note 2" }

    before do
      allow(Rails.logger).to receive(:info)
    end

    it "logs the message" do
      expect(Rails.logger).to receive(:info).with(/#{msg}/)
      dummy.send(:log_info, msg)
    end
  end

  describe "#update_event_audit_notes!(msg)" do
    let(:msg) { "Test note 1" }

    context "when the event doesn't have any event_audits with 'in_progress' status" do
      it "returns nil" do
        expect(dummy.send(:update_event_audit_notes!, msg)).to eq nil
      end

      it "does not update an event_audit record's notes column with the message" do
        expect(EventAudit.where(notes: msg).count).to eq(0)
      end
    end

    context "when the event has one event_audit with 'in_progress' status" do
      let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

      it "finds the event_audit and updates the notes column with the custom note" do
        dummy.send(:update_event_audit_notes!, msg)
        expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
      end
    end

    context "when the event has multiple event_audit with 'in_progress' status" do
      let!(:event_audits_without_note) { create_list(:event_audit, 2, event: event, status: :in_progress) }
      it "updates the last event_audit's notes column with the custom note" do
        dummy.send(:update_event_audit_notes!, msg)
        expect(event_audits_without_note.last.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
      end

      context "when the event_audit already has a note" do
        let(:msg_2) { "Test note 2" }
        context "one note" do
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress)
          end

          it "concatenates the previous note and adds default message between notes" do
            dummy.send(:update_event_audit_notes!, msg)
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: #{msg}")
            dummy.send(:update_event_audit_notes!, msg_2)
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: #{msg} - Note #{Time.zone.now}: #{msg_2}")
          end
        end

        context "two notes" do
          let(:msg_3) { "Test note 3" }
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress)
          end

          it "concatenates the previous notes and adds default message between notes" do
            dummy.send(:update_event_audit_notes!, msg)
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: #{msg}")
            dummy.send(:update_event_audit_notes!, msg_2)
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: #{msg} - Note #{Time.zone.now}: #{msg_2}")
            dummy.send(:update_event_audit_notes!, msg_3)
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: #{msg} - Note #{Time.zone.now}: #{msg_2} -"\
                     " Note #{Time.zone.now}: #{msg_3}")
          end
        end
      end
    end
  end

  describe "#event_audit_concatenated_notes(last_event_audit, msg)" do
    let(:msg) { "Test note" }

    context "when the last event_audit's notes is nil" do
      let!(:last_event_audit) { create(:event_audit, event: event, status: :in_progress) }
      it "returns the custom message" do
        expect(dummy.send(:event_audit_concatenated_notes, last_event_audit, msg))
          .to eq("Note #{Time.zone.now}: #{msg}")
      end
    end

    context "when the last event_audit already has a note" do
      let!(:last_event_audit) do
        create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: #{msg}")
      end
      let(:msg_2) { "Test note 2" }

      it "concatenates the previous notes value with the custom note" do
        expect(dummy.send(:event_audit_concatenated_notes, last_event_audit, msg_2))
          .to eq("#{last_event_audit.notes} - Note #{Time.zone.now}: #{msg_2}")
      end
    end
  end
end
