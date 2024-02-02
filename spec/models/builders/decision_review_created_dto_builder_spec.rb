# frozen_string_literal: true

RSpec.describe Builders::DecisionReviewCreatedDtoBuilder, type: :model do
  describe "#initialize" do
    context "when a decision_review_created object is found" do
      it "should return a DecisionReviewCreatedDtoBuilder object with response and pii attributes(not in payload)" do
      end
    end
    context "when a decision_review_created object is NOT found" do
      it "should return a new empty object dcr dto builder" do
      end
    end
  end

  context "when we instantiate an empty DecisionReviewCreatedDtoBuilder object" do
    describe "#_build_decision_review_created" do
      it "should return a new DecisionReviewCreated object" do
      end
    end

    describe "#_assign" do
      it "should assign attributes of dcr dto builder correctly on correct payload" do
      end
    end

    describe "#_reset" do
      it "should assign attributes of dcr dto builder correctly on correct payload" do
      end
    end

    describe "#_build_intake" do
      it "should return built intake object" do
      end
    end

    describe "#_build_veteran" do
      it "should return built veteran object" do
      end
    end

    describe "#_build_claimant" do
      it "should return built claimant object" do
      end
    end

    describe "#_build_claim_review" do
      it "should return built claim review object" do
      end
    end

    describe "#_build_end_product_establishment" do
      it "should return built epe object" do
      end
    end

    describe "#_build_request_issues" do
      it "should return built request issues object" do
      end
    end

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

    describe "#_build_hash_response" do
      it "should return hash reponse object" do
      end
    end
  end
end
