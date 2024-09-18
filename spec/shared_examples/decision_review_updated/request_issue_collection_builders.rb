# frozen_string_literal: true

RSpec.shared_examples "request_issue_collection_builders" do
  let(:decision_review_updated_event) do
    FactoryBot.create(:event, type: "Events::DecisionReviewUpdatedEvent", message_payload: message_payload)
  end

  describe "#initialize(decision_review_model)" do
    it "initializes a new instance of Builders::DecisionReviewUpdated::RequestIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new instance variable @decision_review_model" do
      expect(builder.instance_variable_get(:@decision_review_model))
        .to be_an_instance_of(Transformers::DecisionReviewUpdated)
    end

    it "initializes a new instance variable @bis_rating_profiles" do
      expect(builder.instance_variable_get(:@bis_rating_profiles))
        .to eq(nil)
    end
  end

  describe "#build_issues" do
    context "when successful" do
      it "creates DecisionReviewUpdated::RequestIssue objects successfully" do
        expect(subject.build_issues.first).to be_an_instance_of(DecisionReviewUpdated::RequestIssue)
      end
    end
  end

  describe "#build_request_issue" do
    before do
      allow(Builders::DecisionReviewUpdated::RequestIssueBuilder).to receive(:build).and_return(true)
    end

    context "when successful" do
      it "does not raise an error" do
        expect(subject.build_request_issue(issue, index)).to eq(true)
      end
    end

    context "when unsuccessful" do
      before do
        allow(Builders::DecisionReviewUpdated::RequestIssueBuilder).to receive(:build).and_raise(StandardError)
      end

      it "raises an error" do
        expect do
          subject.build_request_issue(issue, index)
        end.to raise_error(AppealsConsumer::Error::RequestIssueBuildError)
      end
    end
  end

  describe "#_message_has_rating_issues?" do
    subject { builder.send(:message_has_rating_issues?) }

    context "when rating_ep_code_category? and at_least_one_valid_bis_issue? return true" do
      it "returns true" do
        allow(builder).to receive(:rating_ep_code_category?).and_return(true)
        allow(builder).to receive(:at_least_one_valid_bis_issue?).and_return(true)
        expect(subject).to eq(true)
      end
    end

    context "when rating_ep_code_category? returns false and at_least_one_valid_bis_issue? returns true" do
      it "returns true" do
        allow(builder).to receive(:rating_ep_code_category?).and_return(false)
        allow(builder).to receive(:at_least_one_valid_bis_issue?).and_return(true)
        expect(subject).to eq(false)
      end
    end

    context "when rating_ep_code_category? returns true and at_least_one_valid_bis_issue? returns false" do
      it "returns true" do
        allow(builder).to receive(:rating_ep_code_category?).and_return(true)
        allow(builder).to receive(:at_least_one_valid_bis_issue?).and_return(false)
        expect(subject).to eq(false)
      end
    end
  end

  describe "#initialize_issue_profile_dates" do
    context "when earliest_issue_profile_date and latest_issue_profile_date_plus_one_day return values" do
      let(:date) { "2017-02-07T07:21:24+00:00".to_date }
      let(:date_plus_one) { date + 1 }

      before do
        decision_review_updated.instance_variable_set(:@event_id, decision_review_updated_event.id)
        decision_review_updated.ep_code_category = 'rating'
        issue.prior_rating_decision_id = 1
        issue.prior_decision_rating_profile_date = date.to_s
      end

      it "initializes a new instance variable @earliest_issue_profile_date" do
        expect(builder.instance_variable_get(:@earliest_issue_profile_date)).to eq(date)
      end

      it "initializes a new instance variable @latest_issue_profile_date_plus_one_day" do
        expect(builder.instance_variable_get(:@latest_issue_profile_date_plus_one_day)).to eq(date_plus_one)
      end
    end
  end

  # describe "#fetch_and_set_bis_rating_profiles" do
  #   subject { builder.send(:fetch_and_set_bis_rating_profiles) }
  # end

  describe "#_rating_ep_code_category?" do
    subject { builder.send(:rating_ep_code_category?) }

    context "when decision_review_updated has an ep_code_category of 'RATING'" do
      it "returns true" do
        decision_review_updated.ep_code_category = 'rating'
        expect(subject).to eq(true)
      end
    end

    context "when decision_review_updated does NOT have an ep_code_category of 'RATING'" do
      it "returns false" do
        decision_review_updated.ep_code_category = 'contested'
        expect(subject).to eq(false)
      end
    end
  end

  describe "#_at_least_one_valid_bis_issue?" do
    context "when the issue has a prior_rating_decision_id" do
      it "returns true" do
        issue.prior_rating_decision_id = 1
        expect(builder.send(:at_least_one_valid_bis_issue?)).to eq(true)
      end
    end

    context "when the issue DOES NOT have a prior_rating_decision_id" do
      it "returns false" do
        issue.prior_rating_decision_id = nil
        expect(builder.send(:at_least_one_valid_bis_issue?)).to eq(false)
      end
    end
  end
end