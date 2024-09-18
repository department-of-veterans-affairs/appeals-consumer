# frozen_string_literal: true

RSpec.shared_examples "request_issue_collection_builders" do
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
end