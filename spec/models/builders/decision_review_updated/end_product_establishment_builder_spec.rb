# frozen_string_literal: true

describe Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder do
    let(:message_payload) do
        {
            "claim_id" => 123,
            "original_source" => "CP",
            "decision_review_type" => "HIGHER_LEVEL_REVIEW",
            "veteran_last_name" => "Smith",
            "veteran_first_name" => "John",
            "veteran_participant_id" => Faker::Number.number(digits: 9).to_s,
            "file_number" => Faker::Number.number(digits: 9).to_s,
            "claimant_participant_id" => Faker::Number.number(digits: 9).to_s,
            "ep_code" => "030HLRNR",
            "ep_code_category" => "NON_RATING",
            "claim_received_date" => "2023-08-25",
            "claim_lifecycle_status" => "Ready to Work",
            "payee_code" => "00",
            "modifier" => "01",
            "originated_from_vacols_issue" => false,
            "limited_poa_code" => nil,
            "tracked_item_action" => "ADD_TRACKED_ITEM",
            "informal_conference_tracked_item_id" => "1",
            "informal_conference_requested" => false,
            "same_station_review_requested" => false,
            "update_time" => "1_722_435_298_953",
            "claim_creation_time" => Time.zone.now.to_s,
            "actor_username" => "BVADWISE101",
            "actor_station" => "101",
            "actor_application" => "PASYSACCTCREATE",
            "auto_remand" => false,
            "decision_review_issues_created" => [
                {
                    "decision_review_issue_id" => 22,
                    "contention_id" => 710_002_659,
                    "contention_action" => "ADD_CONTENTION",
                    "reason_for_contention_action" => "NEWLY_ELIGIBLE",
                    "associated_caseflow_request_issue_id" => nil,
                    "unidentified" => false,
                    "prior_rating_decision_id" => nil,
                    "prior_non_rating_decision_id" => nil,
                    "prior_caseflow_decision_issue_id" => nil,
                    "prior_decision_text" => "Service connection for tetnus denied",
                    "prior_decision_type" => "Unknown",
                    "prior_decision_source" => nil,
                    "prior_decision_notification_date" => nil,
                    "prior_decision_date" => nil,
                    "prior_decision_diagnostic_code" => nil,
                    "prior_decision_rating_percentage" => nil,
                    "prior_decision_rating_sn" => nil,
                    "eligible" => true,
                    "eligibility_result" => "ELIGIBLE",
                    "time_override" => nil,
                    "time_override_reason" => nil,
                    "contested" => nil,
                    "soc_opt_in" => false,
                    "legacy_appeal_id" => nil,
                    "legacy_appeal_issue_id" => nil,
                    "prior_decision_award_event_id" => nil,
                    "prior_decision_rating_profile_date" => nil,
                    "source_claim_id_for_remand" => nil,
                    "source_contention_id_for_remand" => nil,
                    "removed" => false,
                    "withdrawn" => false,
                    "decision" => nil
                  }
            ],
            "decision_review_issues_updated" => [],
            "decision_review_issues_removed" => [],
            "decision_review_issues_withdrawn" => [],
            "decision_review_issues_not_changed" => []
          }
    end
    let(:event_id) { 321 }
    let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
    let(:builder) { described_class.new(decision_review_updated_model) }
  
    describe "#build" do
      subject { described_class.build(decision_review_updated_model) }
      it "returns an DecisionReviewUpdated::EndProductEstablishment object" do
        expect(subject).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
      end
    end
  
    describe "#initialize(decision_review_updated)" do
      let(:epe) { described_class.new(decision_review_updated_model).end_product_establishment }
  
      it "initializes a new EndProductEstablishmentBuilder instance" do
        expect(builder).to be_an_instance_of(described_class)
      end
  
      it "initializes a new DecisionReviewUpdated::EndProductEstablishment object" do
        expect(epe).to be_an_instance_of(DecisionReviewUpdated::EndProductEstablishment)
      end
  
      it "assigns decision_review_updated to the DecisionReviewUpdated object passed in" do
        expect(builder.decision_review_updated).to be_an_instance_of(Transformers::DecisionReviewUpdated)
      end
    end
  
    describe "#assign_attributes" do
      it "calls private methods" do
        expect(builder).to receive(:assign_decision_review_updated_development_item_reference_id)
        expect(builder).to receive(:assign_decision_review_updated_reference_id)
  
        builder.assign_attributes
      end
    end
  
    describe "private methods" do
      let!(:builder) { described_class.new(decision_review_updated_model).assign_attributes }
  
      describe "#_assign_development_item_reference_id" do
        subject { builder.end_product_establishment.development_item_reference_id }
        it "should assign a development item referecne id to the epe instance" do
          expect(subject).to eq decision_review_updated_model.informal_conference_tracked_item_id
        end
      end
  
      describe "#_assign_reference_id" do
        it "should assign a reference id to the epe instance" do
          expect(builder.end_product_establishment.reference_id).to eq decision_review_updated_model.claim_id.to_s
        end
      end
    end
  end
  