# frozen_string_literal: true

RSpec.describe Builders::DecisionReviewCreatedDtoBuilder, type: :model do
  message_payload = {
    "claim_id" => 1_234_567,
    "decision_review_type" => "HigherLevelReview",
    "veteran_first_name" => "John",
    "veteran_last_name" => "Smith",
    "veteran_participant_id" => "123456789",
    "file_number" => "123456789",
    "claimant_participant_id" => "01010101",
    "ep_code" => "030HLRNR",
    "ep_code_category" => "Rating",
    "claim_received_date" => Date.new(2022, 1, 1),
    "claim_lifecycle_status" => "RFD",
    "payee_code" => "00",
    "modifier" => "01",
    "originated_from_vacols_issue" => false,
    "informal_conference_requested" => false,
    "same_station_review_requested" => false,
    "intake_creation_time" => Time.now.utc,
    "claim_creation_time" => Time.now.utc,
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
          "prior_decision_notification_date" => Date.new(2022, 1, 1),
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
          "prior_decision_notification_date" => Date.new(2022, 1, 1),
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

  describe "#initialize" do
    context "when a decision_review_created object is found from a mocked payload (before actually building)" do
      let(:dcr_event) { create(:event) }
      let(:dcr) { build(:decision_review_created) }

      it "should return a DecisionReviewCreatedDtoBuilder object with response and pii attributes(not in payload)" do
        allow_any_instance_of(Builders::DecisionReviewCreatedDtoBuilder).to receive(:build_decision_review_created)
          .with(dcr_event.message_payload).and_return(dcr)
        allow_any_instance_of(Builders::DecisionReviewCreatedDtoBuilder).to receive(:assign_attributes)
        expect(Builders::DecisionReviewCreatedDtoBuilder.new(dcr_event)).to have_received(:assign_attributes)
        expect(Builders::DecisionReviewCreatedDtoBuilder.new(dcr_event))
          .to be_instance_of(Builders::DecisionReviewCreatedDtoBuilder)
      end
    end

    # TODO: add test for e2e from raw event.message_payload
    context "when a decision_review_created object is found from a mocked payload (with building from event)" do
      it "should return a DecisionReviewCreatedBuilder with a DCR and associated attributes" do
      end
    end

    context "when a decision_review_created object is NOT found" do
      it "should return a new empty object dcr dto builder" do
        allow_any_instance_of(Builders::DecisionReviewCreatedDtoBuilder).to receive(:reset_attributes)
        expect(Builders::DecisionReviewCreatedDtoBuilder.new).to have_received(:reset_attributes)
        expect(Builders::DecisionReviewCreatedDtoBuilder.new)
          .to be_instance_of(Builders::DecisionReviewCreatedDtoBuilder)
      end
    end
  end

  context "when we instantiate an empty DecisionReviewCreatedDtoBuilder object" do
    describe "#_build_decision_review_created" do
      subject { Builders::DecisionReviewCreatedDtoBuilder.new }

      it "should return a new DecisionReviewCreated object" do
        expect(subject.send(:build_decision_review_created, message_payload)).to be_instance_of(DecisionReviewCreated)
      end
    end

    describe "#_assign_attributes" do
      it "should call various assign methods" do
        expect(subject).to receive(:assign_from_decision_review_created)
        expect(subject).to receive(:assign_from_builders)
        expect(subject).to receive(:assign_from_retrievals)
        expect(subject).to receive(:assign_hash_response)
        subject.send(:assign_attributes)
      end
    end

    describe "#_assign_from_decision_review_created" do
      let(:dcr) { build(:decision_review_created) }
      let(:dcr_dto_builder) do
        Builders::DecisionReviewCreatedDtoBuilder.new.tap do |dcr_dto_builder|
          dcr_dto_builder.instance_variable_set(:@decision_review_created, dcr)
        end
      end

      it "should assign instance variables based on decision_review_created" do
        dcr_dto_builder.instance_variable_set(:@decision_review_created, dcr)
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
        it "should recieve the following methods:" do
          expect(subject).to receive(:build_intake)
          expect(subject).to receive(:build_veteran)
          expect(subject).to receive(:build_claimant)
          expect(subject).to receive(:build_claim_review)
          expect(subject).to receive(:build_end_product_establishment)
          expect(subject).to receive(:build_request_issues)
          subject.send(:assign_from_builders)
        end
      end

      context "should handle an error" do
        let(:dcr_dto_builder) { Builders::DecisionReviewCreatedDtoBuilder.new }
        it "should raise an error" do
          dcr_dto_builder.instance_eval do
            def build_intake
              fail StandardError
            end
          end
          expect { dcr_dto_builder.send(:assign_from_builders) }.to raise_error(Builders::DtoBuilder::DtoBuildError)
        end
      end
    end

    describe "#_assign_from_retrievals" do
      it "should receive the following methods: " do
        expect(subject).to receive(:retrieve_vet_ssn)
        expect(subject).to receive(:retrieve_vet_middle_name)
        expect(subject).to receive(:retrieve_claimant_ssn)
        expect(subject).to receive(:retrieve_claimant_dob)
        expect(subject).to receive(:retrieve_claimant_first_name)
        expect(subject).to receive(:retrieve_claimant_middle_name)
        expect(subject).to receive(:retrieve_claimant_last_name)
        expect(subject).to receive(:retrieve_claimant_email)
        subject.send(:assign_from_retrievals)

        # TODO: instance_variable_get after implementation to verify correctness
      end
    end

    describe "#_assign_hash_response" do
      it "should recieve the following methods: " do
        expect(subject).to receive(:build_hash_response)
        expect(subject).to receive(:validate_no_pii)
        subject.send(:assign_hash_response)
      end
    end

    describe "#_reset_attributes" do
      it "should assign attributes of dcr dto builder correctly on correct payload" do
        subject.send(:reset_attributes)
        expect(subject.instance_variable_get(:@css_id).nil?).to eq true
        expect(subject.instance_variable_get(:@detail_type).nil?).to eq true
        expect(subject.instance_variable_get(:@station).nil?).to eq true
        expect(subject.instance_variable_get(:@intake).nil?).to eq true
        expect(subject.instance_variable_get(:@veteran).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant).nil?).to eq true
        expect(subject.instance_variable_get(:@claim_review).nil?).to eq true
        expect(subject.instance_variable_get(:@end_product_establishment).nil?).to eq true
        expect(subject.instance_variable_get(:@request_issues).nil?).to eq true
        expect(subject.instance_variable_get(:@vet_file_number).nil?).to eq true
        expect(subject.instance_variable_get(:@vet_ssn).nil?).to eq true
        expect(subject.instance_variable_get(:@vet_first_name).nil?).to eq true
        expect(subject.instance_variable_get(:@vet_middle_name).nil?).to eq true
        expect(subject.instance_variable_get(:@vet_last_name).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_ssn).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_dob).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_first_name).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_middle_name).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_last_name).nil?).to eq true
        expect(subject.instance_variable_get(:@claimant_email).nil?).to eq true
        expect(subject.instance_variable_get(:@hash_response).nil?).to eq true
      end
    end

    describe "builder methods" do
      let(:dcr) { build(:decision_review_created) }
      let(:dcr_dto_builder) do
        Builders::DecisionReviewCreatedDtoBuilder.new.tap do |dcr_dto_builder|
          dcr_dto_builder.instance_variable_set(:@decision_review_created, dcr)
        end
      end

      describe "#_build_intake" do
        it "should return built intake object" do
          expect(dcr_dto_builder.send(:build_intake)).to be_instance_of(Intake)
        end
      end

      describe "#_build_veteran" do
        it "should return built veteran object" do
          expect(dcr_dto_builder.send(:build_veteran)).to be_instance_of(Veteran)
        end
      end

      describe "#_build_claimant" do
        it "should return built claimant object" do
          expect(dcr_dto_builder.send(:build_claimant)).to be_instance_of(Claimant)
        end
      end

      describe "#_build_claim_review" do
        it "should return built claim review object" do
          expect(dcr_dto_builder.send(:build_claim_review)).to be_instance_of(ClaimReview)
        end
      end

      describe "#_build_end_product_establishment" do
        it "should return built epe object" do
          expect(dcr_dto_builder.send(:build_end_product_establishment)).to be_instance_of(EndProductEstablishment)
        end
      end

      describe "#_build_request_issues" do
        it "should return built request issues object" do
          expect(dcr_dto_builder.send(:build_request_issues)).to be_instance_of(Array)
        end
      end
    end

    # TODO: finish "_retrieve..." method specs on implementation

    describe "retrieval methods" do
      describe "#_retrieve_vet_ssn" do
        it "should return vet ssn" do
        end
      end

      describe "#_retrieve_vet_middle_name" do
        it "should return vet middle name" do
        end
      end

      describe "#_retrieve_claimant_ssn" do
        it "should return claimant ssn" do
        end
      end

      describe "#_retrieve_claimant_dob" do
        it "should return claimant dob" do
        end
      end

      describe "#_retrieve_claimant_first_name" do
        it "should return cliamant first name" do
        end
      end

      describe "#_retrieve_claimant_middle_name" do
        it "should return claimant middle name" do
        end
      end

      describe "#_retrieve_claimant_last_name" do
        it "should return claimant last name" do
        end
      end

      describe "#_retrieve_claimant_email" do
        it "should return claimant email" do
        end
      end
    end

    describe "#_build_hash_response" do
      it "should return hash reponse object" do
        subject.instance_variable_set(:@css_id, 1)
        subject.instance_variable_set(:@detail_type, "HigherLevelReview")
        subject.instance_variable_set(:@station, "101")
        subject.instance_variable_set(:@intake, Intake.new)
        subject.instance_variable_set(:@veteran, Veteran.new)
        subject.instance_variable_set(:@claimant, Claimant.new)
        subject.instance_variable_set(:@claim_review, ClaimReview.new)
        subject.instance_variable_set(:@end_product_establishment, EndProductEstablishment.new)
        subject.instance_variable_set(:@request_issues, [])

        built_hash = subject.send(:build_hash_response)

        expect(built_hash["css_id"]).to eq 1
        expect(built_hash["detail_type"]).to eq "HigherLevelReview"
        expect(built_hash["station"]).to eq "101"
        expect(built_hash["intake"].blank?).to eq true
        expect(built_hash["veteran"].blank?).to eq true
        expect(built_hash["claimant"].blank?).to eq true
        expect(built_hash["claim_review"].blank?).to eq true
        expect(built_hash["end_product_establishment"].blank?).to eq true
        expect(built_hash["request_issues"].blank?).to eq true
      end
    end
  end
end
