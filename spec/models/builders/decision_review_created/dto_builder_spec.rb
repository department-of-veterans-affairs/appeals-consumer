# frozen_string_literal: true

# TODO: finish "_retrieve..." method specs on implementation
# TODO: instance_variable_get after implementation to verify correctness for retrievals

RSpec.describe Builders::DecisionReviewCreated::DtoBuilder, type: :model do
  message_payload = {
    "claim_id" => 1_234_567,
    "decision_review_type" => "HIGHER_LEVEL_REVIEW",
    "veteran_first_name" => "John",
    "veteran_last_name" => "Smith",
    "veteran_participant_id" => "123456789",
    "file_number" => "123456789",
    "claimant_participant_id" => "01010101",
    "ep_code" => "030HLRNR",
    "ep_code_category" => "Rating",
    "claim_received_date" => "2023-08-25",
    "claim_lifecycle_status" => "RFD",
    "payee_code" => "00",
    "modifier" => "01",
    "originated_from_vacols_issue" => false,
    "informal_conference_requested" => false,
    "informal_conference_tracked_item_id" => "1",
    "same_station_review_requested" => false,
    "intake_creation_time" => Time.now.utc.to_s,
    "claim_creation_time" => Time.now.utc.to_s,
    "actor_username" => "BVADWISE101",
    "actor_station" => "101",
    "actor_application" => "PASYSACCTCREATE",
    "auto_remand" => false,
    "decision_review_issues" =>
      [
        {
          "contention_id" => 123_456_789,
          "associated_caseflow_request_issue_id" => nil,
          "unidentified" => false,
          "prior_rating_decision_id" => nil,
          "prior_non_rating_decision_id" => 12,
          "prior_decision_text" => "service connection for tetnus denied",
          "prior_decision_type" => "DIC",
          "prior_decision_notification_date" => "2023-08-01",
          "prior_decision_date" => "2023-08-01",
          "prior_decision_diagnostic_code" => nil,
          "prior_decision_rating_percentage" => nil,
          "eligible" => true,
          "eligibility_result" => "ELIGIBLE",
          "time_override" => nil,
          "time_override_reason" => nil,
          "contested" => nil,
          "soc_opt_in" => nil,
          "legacy_appeal_id" => nil,
          "legacy_appeal_issue_id" => nil
        },
        {
          "contention_id" => 987_654_321,
          "associated_caseflow_request_issue_id" => nil,
          "unidentified" => false,
          "prior_rating_decision_id" => nil,
          "prior_non_rating_decision_id" => 13,
          "prior_decision_text" => "service connection for ear infection denied",
          "prior_decision_type" => "Basic Eligibility",
          "prior_decision_notification_date" => "2023-08-01",
          "prior_decision_date" => "2023-08-01",
          "prior_decision_diagnostic_code" => nil,
          "prior_decision_rating_percentage" => nil,
          "eligible" => true,
          "eligibility_result" => "ELIGIBLE",
          "time_override" => nil,
          "time_override_reason" => nil,
          "contested" => nil,
          "soc_opt_in" => nil,
          "legacy_appeal_id" => nil,
          "legacy_appeal_issue_id" => nil
        }
      ]
  }

  let(:veteran_bis_record) do
    {
      file_number: message_payload["file_number"],
      ptcpnt_id: message_payload["veteran_participant_id"],
      sex: "M",
      first_name: message_payload["veteran_first_name"],
      middle_name: "Russell",
      last_name: message_payload["veteran_last_name"],
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

  let(:store_veteran_record) do
    Fakes::VeteranStore.new.store_veteran_record(message_payload["file_number"], veteran_bis_record)
  end

  describe "#initialize" do
    context "when a decision_review_created object is found from a mocked payload (before actually building)" do
      let(:drc_event) { create(:event, message_payload: message_payload.to_json) }
      let(:drc) { build(:decision_review_created) }

      it "should return a DecisionReviewCreatedDtoBuilder object with response and pii attributes(not in payload)" do
        allow_any_instance_of(Builders::DecisionReviewCreated::DtoBuilder).to receive(:build_decision_review_created)
          .with(JSON.parse(drc_event.message_payload)).and_return(drc)
        allow_any_instance_of(Builders::DecisionReviewCreated::DtoBuilder).to receive(:assign_attributes)
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(drc_event)).to have_received(:assign_attributes)
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(drc_event))
          .to be_instance_of(Builders::DecisionReviewCreated::DtoBuilder)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        Builders::DecisionReviewCreated::DtoBuilder.new(drc_event)
      end
    end

    context "when a decision_review_created object is found from a mocked payload (with building from event)" do
      before do
        store_veteran_record
      end

      let(:drc_event) { build(:event, message_payload: message_payload.to_json) }

      it "should return a DecisionReviewCreatedBuilder with a drc and associated attributes" do
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(drc_event))
          .to be_instance_of(Builders::DecisionReviewCreated::DtoBuilder)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        Builders::DecisionReviewCreated::DtoBuilder.new(drc_event)
      end
    end
  end

  context "when there is a DecisionReviewCreated object" do
    let(:builder) { Builders::DecisionReviewCreated::DtoBuilder.new(build(:decision_review_created_event)) }

    let(:drc) { build(:decision_review_created) }
    let!(:drc_dto_builder) do
      builder.tap do |drc_dto_builder|
        drc_dto_builder.instance_variable_set(:@decision_review_created, drc)
      end
    end

    describe "#_build_decision_review_created" do
      let(:new_builder) { builder }

      it "should return a new DecisionReviewCreated object" do
        expect(builder.send(:build_decision_review_created, message_payload))
          .to be_instance_of(Transformers::DecisionReviewCreated)
      end
    end

    describe "#_assign_attributes" do
      it "should call various assign methods" do
        expect(drc_dto_builder).to receive(:assign_from_decision_review_created)
        expect(drc_dto_builder).to receive(:assign_from_builders)
        expect(drc_dto_builder).to receive(:assign_from_retrievals)
        expect(drc_dto_builder).to receive(:assign_payload)
        drc_dto_builder.send(:assign_attributes)
      end
    end

    describe "#_assign_from_decision_review_created" do
      it "should assign instance variables based on decision_review_created" do
        # _assign_from_decision_review_created is dependent on call before it of _assign_from_builders
        drc_dto_builder.send(:assign_from_builders)
        drc_dto_builder.send(:assign_from_decision_review_created)

        expect(drc_dto_builder.instance_variable_get(:@decision_review_created)).to eq drc
        expect(drc_dto_builder.instance_variable_get(:@css_id)).to eq drc.actor_username
        expect(drc_dto_builder.instance_variable_get(:@station)).to eq drc.actor_station
        expect(drc_dto_builder.instance_variable_get(:@detail_type))
          .to eq builder.instance_variable_get(:@intake).instance_variable_get(:@detail_type)
        expect(drc_dto_builder.instance_variable_get(:@vet_file_number)).to eq drc.file_number
        expect(drc_dto_builder.instance_variable_get(:@vet_first_name)).to eq drc.veteran_first_name
        expect(drc_dto_builder.instance_variable_get(:@vet_last_name)).to eq drc.veteran_last_name
      end
    end

    describe "#_assign_from_builders" do
      context "should not throw an error" do
        before do
          store_veteran_record
        end

        it "should recieve the following methods:" do
          expect(drc_dto_builder).to receive(:build_intake)
          expect(drc_dto_builder).to receive(:build_veteran)
          expect(drc_dto_builder).to receive(:build_claimant)
          expect(drc_dto_builder).to receive(:build_claim_review)
          expect(drc_dto_builder).to receive(:build_end_product_establishment)
          expect(drc_dto_builder).to receive(:build_request_issues)
          drc_dto_builder.send(:assign_from_builders)
        end

        it "should assign correct ivars" do
          drc_dto_builder.send(:assign_attributes)
          expect(drc_dto_builder.instance_variable_get(:@intake)).to be_instance_of(DecisionReviewCreated::Intake)
          expect(drc_dto_builder.instance_variable_get(:@veteran)).to be_instance_of(DecisionReviewCreated::Veteran)
          expect(drc_dto_builder.instance_variable_get(:@claimant)).to be_instance_of(DecisionReviewCreated::Claimant)
          expect(drc_dto_builder.instance_variable_get(:@claim_review))
            .to be_instance_of(DecisionReviewCreated::ClaimReview)
          expect(drc_dto_builder.instance_variable_get(:@end_product_establishment))
            .to be_instance_of(DecisionReviewCreated::EndProductEstablishment)
          expect(drc_dto_builder.instance_variable_get(:@request_issues)).to be_instance_of(Array)
          expect(drc_dto_builder.instance_variable_get(:@request_issues).flatten.first)
            .to be_instance_of(DecisionReviewCreated::RequestIssue)
        end
      end

      context "should raise error if error in builder methods" do
        it "should raise an error" do
          builder.instance_eval do
            def build_intake
              fail StandardError
            end
          end
          expect { builder.send(:assign_from_builders) }.to raise_error(AppealsConsumer::Error::DtoBuildError)
        end
      end
    end

    describe "#_assign_from_retrievals" do
      it "should receive the following methods: " do
        expect(builder).to receive(:assign_vet_ssn)
        expect(builder).to receive(:assign_vet_middle_name)
        expect(builder).to receive(:assign_claimant_ssn)
        expect(builder).to receive(:assign_claimant_dob)
        expect(builder).to receive(:assign_claimant_first_name)
        expect(builder).to receive(:assign_claimant_middle_name)
        expect(builder).to receive(:assign_claimant_last_name)
        expect(builder).to receive(:assign_claimant_email)
        builder.send(:assign_from_retrievals)

        # instance_variable_get after implementation to verify correctness
      end
    end

    describe "#_assign_payload" do
      it "should recieve the following methods: " do
        expect(drc_dto_builder).to receive(:build_payload)
        expect(drc_dto_builder).to receive(:validate_no_pii)
        drc_dto_builder.send(:assign_payload)
      end
      it "should assing to @payload" do
        drc_dto_builder.send(:assign_payload)
        expect(drc_dto_builder.instance_variable_get(:@payload)).to be_instance_of(Hash)
      end
    end

    describe "builder methods" do
      let(:drc) { build(:decision_review_created) }
      let(:drc_dto_builder) do
        builder.tap do |drc_dto_builder|
          drc_dto_builder.instance_variable_set(:@decision_review_created, drc)
        end
      end

      describe "#_build_intake" do
        it "should return built intake object" do
          expect(drc_dto_builder.send(:build_intake)).to be_instance_of(DecisionReviewCreated::Intake)
        end
      end

      describe "#_build_veteran" do
        before do
          store_veteran_record
        end

        it "should return built veteran object" do
          expect(drc_dto_builder.send(:build_veteran)).to be_instance_of(DecisionReviewCreated::Veteran)
        end
      end

      describe "#_build_claimant" do
        it "should return built claimant object" do
          expect(drc_dto_builder.send(:build_claimant)).to be_instance_of(DecisionReviewCreated::Claimant)
        end
      end

      describe "#_build_claim_review" do
        it "should return built claim review object" do
          expect(drc_dto_builder.send(:build_claim_review)).to be_instance_of(DecisionReviewCreated::ClaimReview)
        end
      end

      describe "#_build_end_product_establishment" do
        before do
          store_veteran_record
        end

        it "should return built epe object" do
          expect(drc_dto_builder.send(:build_end_product_establishment))
            .to be_instance_of(DecisionReviewCreated::EndProductEstablishment)
        end
      end

      describe "#_build_request_issues" do
        it "should return built request issues object" do
          expect(drc_dto_builder.send(:build_request_issues)).to be_instance_of(Array)
        end
      end
    end

    describe "#_build_payload" do
      it "should return hash reponse object" do
        drc_dto_builder.instance_variable_set(:@css_id, 1)
        drc_dto_builder.instance_variable_set(:@detail_type, "HIGHER_LEVEL_REVIEW")
        drc_dto_builder.instance_variable_set(:@station, "101")
        drc_dto_builder.instance_variable_set(:@intake, DecisionReviewCreated::Intake.new)
        drc_dto_builder.instance_variable_set(:@veteran, DecisionReviewCreated::Veteran.new)
        drc_dto_builder.instance_variable_set(:@claimant, DecisionReviewCreated::Claimant.new)
        drc_dto_builder.instance_variable_set(:@claim_review, DecisionReviewCreated::ClaimReview.new)
        drc_dto_builder
          .instance_variable_set(:@end_product_establishment, DecisionReviewCreated::EndProductEstablishment.new)
        drc_dto_builder.instance_variable_set(:@request_issues, [])

        built_hash = drc_dto_builder.send(:build_payload)

        expect(built_hash["css_id"]).to eq 1
        expect(built_hash["detail_type"]).to eq "HIGHER_LEVEL_REVIEW"
        expect(built_hash["station"]).to eq "101"
        expect(built_hash["intake"].blank?).to eq true
        expect(built_hash["veteran"].blank?).to eq true
        expect(built_hash["claimant"].blank?).to eq true
        expect(built_hash["claim_review"].blank?).to eq true
        expect(built_hash["end_product_establishment"].blank?).to eq true
        expect(built_hash["request_issues"].blank?).to eq true
      end
    end

    # finish "_retrieve..." method specs on implementation

    describe "retrieval methods" do
      let(:veteran) { build(:veteran) }
      let(:claimant) { build(:claimant) }
      let(:drc_dto_builder) do
        builder.tap do |drc_dto_builder|
          drc_dto_builder.instance_variable_set(:@veteran, veteran)
          drc_dto_builder.instance_variable_set(:@claimant, claimant)
        end
      end

      describe "#_assign_vet_ssn" do
        it "should return vet ssn" do
          expect(drc_dto_builder.send(:assign_vet_ssn)).to eq veteran.ssn
        end
      end

      describe "#_assign_vet_middle_name" do
        it "should return vet middle name" do
          expect(drc_dto_builder.send(:assign_vet_middle_name)).to eq veteran.middle_name
        end
      end

      describe "#_assign_claimant_ssn" do
        it "should return claimant ssn" do
          expect(drc_dto_builder.send(:assign_claimant_ssn)).to eq claimant.ssn
        end
      end

      describe "#_assign_claimant_dob" do
        it "should return claimant dob" do
          expect(drc_dto_builder.send(:assign_claimant_dob)).to eq claimant.date_of_birth
        end
      end

      describe "#_assign_claimant_first_name" do
        it "should return cliamant first name" do
          expect(drc_dto_builder.send(:assign_claimant_first_name)).to eq claimant.first_name
        end
      end

      describe "#_assign_claimant_middle_name" do
        it "should return claimant middle name" do
          expect(drc_dto_builder.send(:assign_claimant_middle_name)).to eq claimant.middle_name
        end
      end

      describe "#_assign_claimant_last_name" do
        it "should return claimant last name" do
          expect(drc_dto_builder.send(:assign_claimant_last_name)).to eq claimant.last_name
        end
      end

      describe "#_assign_claimant_email" do
        it "should return claimant email" do
          expect(drc_dto_builder.send(:assign_claimant_email)).to eq claimant.email
        end
      end
    end
  end
end
