# frozen_string_literal: true

# TODO: finish "_retrieve..." method specs on implementation
# TODO: instance_variable_get after implementation to verify correctness for retrievals
# TODO: add sentry/slack notifications if necessary

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
    "created_by_username" => "BVADWISE101",
    "created_by_station" => "101",
    "created_by_application" => "PASYSACCTCREATE",
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
      let(:dcr_event) { create(:event, message_payload: message_payload.to_json) }
      let(:dcr) { build(:decision_review_created) }

      it "should return a DecisionReviewCreatedDtoBuilder object with response and pii attributes(not in payload)" do
        allow_any_instance_of(Builders::DecisionReviewCreated::DtoBuilder).to receive(:build_decision_review_created)
          .with(JSON.parse(dcr_event.message_payload)).and_return(dcr)
        allow_any_instance_of(Builders::DecisionReviewCreated::DtoBuilder).to receive(:assign_attributes)
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(dcr_event)).to have_received(:assign_attributes)
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(dcr_event))
          .to be_instance_of(Builders::DecisionReviewCreated::DtoBuilder)
      end
    end

    context "when a decision_review_created object is found from a mocked payload (with building from event)" do
      before do
        store_veteran_record
      end

      let(:dcr_event) { build(:event, message_payload: message_payload.to_json) }

      it "should return a DecisionReviewCreatedBuilder with a DCR and associated attributes" do
        expect(Builders::DecisionReviewCreated::DtoBuilder.new(dcr_event))
          .to be_instance_of(Builders::DecisionReviewCreated::DtoBuilder)
      end
    end
  end

  context "when there is a DecisionReviewCreated object" do
    before(:all) do
      Builders::DecisionReviewCreated::DtoBuilder.class_eval do
        def initialize
          super()
          @decision_review_created = nil
        end
      end
    end

    after(:all) do
      Builders::DecisionReviewCreated::DtoBuilder.class_eval do
        def initialize(dcr_event)
          super()
          @decision_review_created = build_decision_review_created(JSON.parse(dcr_event.message_payload))
          assign_attributes
        end
      end
    end

    let(:dcr) { build(:decision_review_created) }
    let!(:dcr_dto_builder) do
      Builders::DecisionReviewCreated::DtoBuilder.new.tap do |dcr_dto_builder|
        dcr_dto_builder.instance_variable_set(:@decision_review_created, dcr)
      end
    end

    describe "#_build_decision_review_created" do
      let(:new_builder) { Builders::DecisionReviewCreated::DtoBuilder.new }

      it "should return a new DecisionReviewCreated object" do
        expect(new_builder.send(:build_decision_review_created, message_payload))
          .to be_instance_of(Mappers::DecisionReviewCreated)
      end
    end

    describe "#_assign_attributes" do
      it "should call various assign methods" do
        expect(dcr_dto_builder).to receive(:assign_from_decision_review_created)
        expect(dcr_dto_builder).to receive(:assign_from_builders)
        expect(dcr_dto_builder).to receive(:assign_from_retrievals)
        expect(dcr_dto_builder).to receive(:assign_hash_response)
        dcr_dto_builder.send(:assign_attributes)
      end
    end

    describe "#_assign_from_decision_review_created" do
      it "should assign instance variables based on decision_review_created" do
        dcr_dto_builder.send(:assign_from_decision_review_created)

        expect(dcr_dto_builder.instance_variable_get(:@decision_review_created)).to eq dcr
        expect(dcr_dto_builder.instance_variable_get(:@css_id)).to eq dcr.created_by_username
        expect(dcr_dto_builder.instance_variable_get(:@station)).to eq dcr.created_by_station
        expect(dcr_dto_builder.instance_variable_get(:@detail_type)).to eq dcr.decision_review_type
        expect(dcr_dto_builder.instance_variable_get(:@vet_file_number)).to eq dcr.file_number
        expect(dcr_dto_builder.instance_variable_get(:@vet_first_name)).to eq dcr.veteran_first_name
        expect(dcr_dto_builder.instance_variable_get(:@vet_last_name)).to eq dcr.veteran_last_name
      end
    end

    describe "#_assign_from_builders" do
      context "should not throw an error" do
        before do
          store_veteran_record
        end

        it "should recieve the following methods:" do
          expect(dcr_dto_builder).to receive(:build_intake)
          expect(dcr_dto_builder).to receive(:build_veteran)
          expect(dcr_dto_builder).to receive(:build_claimant)
          expect(dcr_dto_builder).to receive(:build_claim_review)
          expect(dcr_dto_builder).to receive(:build_end_product_establishment)
          expect(dcr_dto_builder).to receive(:build_request_issues)
          dcr_dto_builder.send(:assign_from_builders)
        end

        it "should assign correct ivars" do
          dcr_dto_builder.send(:assign_attributes)
          expect(dcr_dto_builder.instance_variable_get(:@intake)).to be_instance_of(DecisionReviewCreated::Intake)
          expect(dcr_dto_builder.instance_variable_get(:@veteran)).to be_instance_of(DecisionReviewCreated::Veteran)
          expect(dcr_dto_builder.instance_variable_get(:@claimant)).to be_instance_of(DecisionReviewCreated::Claimant)
          expect(dcr_dto_builder.instance_variable_get(:@claim_review))
            .to be_instance_of(DecisionReviewCreated::ClaimReview)
          expect(dcr_dto_builder.instance_variable_get(:@end_product_establishment))
            .to be_instance_of(DecisionReviewCreated::EndProductEstablishment)
          expect(dcr_dto_builder.instance_variable_get(:@request_issues)).to be_instance_of(Array)
          expect(dcr_dto_builder.instance_variable_get(:@request_issues).flatten.first)
            .to be_instance_of(DecisionReviewCreated::RequestIssue)
        end
      end

      context "should raise error if error in builder methods" do
        let(:dcr_dto_builder) { Builders::DecisionReviewCreated::DtoBuilder.new }
        it "should raise an error" do
          dcr_dto_builder.instance_eval do
            def build_intake
              fail StandardError
            end
          end
          expect { dcr_dto_builder.send(:assign_from_builders) }.to raise_error(Builders::BaseDtoBuilder::DtoBuildError)
        end
      end
    end

    describe "#_assign_from_retrievals" do
      it "should receive the following methods: " do
        expect(dcr_dto_builder).to receive(:assign_vet_ssn)
        expect(dcr_dto_builder).to receive(:assign_vet_middle_name)
        expect(dcr_dto_builder).to receive(:assign_claimant_ssn)
        expect(dcr_dto_builder).to receive(:assign_claimant_dob)
        expect(dcr_dto_builder).to receive(:assign_claimant_first_name)
        expect(dcr_dto_builder).to receive(:assign_claimant_middle_name)
        expect(dcr_dto_builder).to receive(:assign_claimant_last_name)
        expect(dcr_dto_builder).to receive(:assign_claimant_email)
        dcr_dto_builder.send(:assign_from_retrievals)

        # instance_variable_get after implementation to verify correctness
      end
    end

    describe "#_assign_hash_response" do
      it "should recieve the following methods: " do
        expect(dcr_dto_builder).to receive(:build_hash_response)
        expect(dcr_dto_builder).to receive(:validate_no_pii)
        dcr_dto_builder.send(:assign_hash_response)
      end
      it "should assing to @hash_response" do
        dcr_dto_builder.send(:assign_hash_response)
        expect(dcr_dto_builder.instance_variable_get(:@hash_response)).to be_instance_of(Hash)
      end
    end

    describe "accessor fields" do
      it "should return nil on DecisionReviewCreatedDtoBuilder with empty decision_review_created" do
        expect(dcr_dto_builder.vet_file_number).to eq nil
        expect(dcr_dto_builder.vet_ssn).to eq nil
        expect(dcr_dto_builder.vet_first_name).to eq nil
        expect(dcr_dto_builder.vet_middle_name).to eq nil
        expect(dcr_dto_builder.vet_last_name).to eq nil
        expect(dcr_dto_builder.claimant_ssn).to eq nil
        expect(dcr_dto_builder.claimant_dob).to eq nil
        expect(dcr_dto_builder.claimant_first_name).to eq nil
        expect(dcr_dto_builder.claimant_middle_name).to eq nil
        expect(dcr_dto_builder.claimant_last_name).to eq nil
        expect(dcr_dto_builder.claimant_email).to eq nil
      end
    end

    describe "builder methods" do
      let(:dcr) { build(:decision_review_created) }
      let(:dcr_dto_builder) do
        Builders::DecisionReviewCreated::DtoBuilder.new.tap do |dcr_dto_builder|
          dcr_dto_builder.instance_variable_set(:@decision_review_created, dcr)
        end
      end

      describe "#_build_intake" do
        it "should return built intake object" do
          expect(dcr_dto_builder.send(:build_intake)).to be_instance_of(DecisionReviewCreated::Intake)
        end
      end

      describe "#_build_veteran" do
        before do
          store_veteran_record
        end

        it "should return built veteran object" do
          expect(dcr_dto_builder.send(:build_veteran)).to be_instance_of(DecisionReviewCreated::Veteran)
        end
      end

      describe "#_build_claimant" do
        it "should return built claimant object" do
          expect(dcr_dto_builder.send(:build_claimant)).to be_instance_of(DecisionReviewCreated::Claimant)
        end
      end

      describe "#_build_claim_review" do
        it "should return built claim review object" do
          expect(dcr_dto_builder.send(:build_claim_review)).to be_instance_of(DecisionReviewCreated::ClaimReview)
        end
      end

      describe "#_build_end_product_establishment" do
        before do
          store_veteran_record
        end

        it "should return built epe object" do
          expect(dcr_dto_builder.send(:build_end_product_establishment))
            .to be_instance_of(DecisionReviewCreated::EndProductEstablishment)
        end
      end

      describe "#_build_request_issues" do
        it "should return built request issues object" do
          expect(dcr_dto_builder.send(:build_request_issues)).to be_instance_of(Array)
        end
      end
    end

    describe "#_build_hash_response" do
      it "should return hash reponse object" do
        dcr_dto_builder.instance_variable_set(:@css_id, 1)
        dcr_dto_builder.instance_variable_set(:@detail_type, "HIGHER_LEVEL_REVIEW")
        dcr_dto_builder.instance_variable_set(:@station, "101")
        dcr_dto_builder.instance_variable_set(:@intake, DecisionReviewCreated::Intake.new)
        dcr_dto_builder.instance_variable_set(:@veteran, DecisionReviewCreated::Veteran.new)
        dcr_dto_builder.instance_variable_set(:@claimant, DecisionReviewCreated::Claimant.new)
        dcr_dto_builder.instance_variable_set(:@claim_review, DecisionReviewCreated::ClaimReview.new)
        dcr_dto_builder
          .instance_variable_set(:@end_product_establishment, DecisionReviewCreated::EndProductEstablishment.new)
        dcr_dto_builder.instance_variable_set(:@request_issues, [])

        built_hash = dcr_dto_builder.send(:build_hash_response)

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
      let(:dcr_dto_builder) do
        Builders::DecisionReviewCreated::DtoBuilder.new.tap do |dcr_dto_builder|
          dcr_dto_builder.instance_variable_set(:@veteran, veteran)
          dcr_dto_builder.instance_variable_set(:@claimant, claimant)
        end
      end

      describe "#_assign_vet_ssn" do
        it "should return vet ssn" do
          expect(dcr_dto_builder.send(:assign_vet_ssn)).to eq veteran.ssn
        end
      end

      describe "#_assign_vet_middle_name" do
        it "should return vet middle name" do
          expect(dcr_dto_builder.send(:assign_vet_middle_name)).to eq veteran.middle_name
        end
      end

      describe "#_assign_claimant_ssn" do
        it "should return claimant ssn" do
          expect(dcr_dto_builder.send(:assign_claimant_ssn)).to eq claimant.ssn
        end
      end

      describe "#_assign_claimant_dob" do
        it "should return claimant dob" do
          expect(dcr_dto_builder.send(:assign_claimant_dob)).to eq claimant.date_of_birth
        end
      end

      describe "#_assign_claimant_first_name" do
        it "should return cliamant first name" do
          expect(dcr_dto_builder.send(:assign_claimant_first_name)).to eq claimant.first_name
        end
      end

      describe "#_assign_claimant_middle_name" do
        it "should return claimant middle name" do
          expect(dcr_dto_builder.send(:assign_claimant_middle_name)).to eq claimant.middle_name
        end
      end

      describe "#_assign_claimant_last_name" do
        it "should return claimant last name" do
          expect(dcr_dto_builder.send(:assign_claimant_last_name)).to eq claimant.last_name
        end
      end

      describe "#_assign_claimant_email" do
        it "should return claimant email" do
          expect(dcr_dto_builder.send(:assign_claimant_email)).to eq claimant.email
        end
      end
    end
  end
end
