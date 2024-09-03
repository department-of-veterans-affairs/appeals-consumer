# frozen_string_literal: true

describe Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder do
  let(:decision_review_model) { build(:decision_review_updated, :eligible_rating_hlr_veteran_claimant) }
  let(:decision_review_issues_removed) { decision_review_model.decision_review_issues_removed }
  let(:request_issues) { described_class.build(decision_review_model) }
  let(:builder) { described_class.new(decision_review_model) }
  let(:index) { decision_review_issues_removed.index(issue) }
  let(:issue) { decision_review_issues_removed.first }
  let(:claim_id) { decision_review_model.claim_id }

  describe "#self.build(decision_review_model)" do
    it "initializes an instance of Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder)
    end

    it "returns an array of DecisionReviewUpdated::RequestIssue(s) for every REMOVED issue in the "\
    "decision_review_issues_removed array" do
      expect(request_issues.count).to eq(decision_review_issues_removed.count)
      expect(request_issues).to all(be_an_instance_of(DecisionReviewUpdated::RequestIssue))
    end
  end

  describe "#initialize(decision_review_model)" do
    it "initializes a new instance of Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder" do
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
    describe "with valid removed issues" do
      subject { builder.build_issues }
      let(:decision_review_model) do
        build(:decision_review_updated, :eligible_rating_hlr_veteran_claimant)
      end
      let(:decision_review_issues_removed) { decision_review_model.decision_review_issues_removed }

      it "maps VALID decision_review_issues_removed into an array of DecisionReviewUpdated::RequestIssue(s)" do
        expect(subject).to all(be_an_instance_of(DecisionReviewUpdated::RequestIssue))
        expect(subject).to be_an_instance_of(Array)
        expect(subject.length).to eq(decision_review_issues_removed.length)
      end
    end

    describe "with invalid removed issues" do
      subject { builder.build_issues }
      let(:decision_review_model) do
        build(:decision_review_updated, :rating_hlr_with_an_invalid_removed_issue)
      end
      let(:decision_review_issues_removed) { decision_review_model.decision_review_issues_removed }

      it "DOES NOT map INVALID decision_review_issues_removed into an array of DecisionReviewUpdated::RequestIssue(s)" do
        expect(subject).to all(be_an_instance_of(DecisionReviewUpdated::RequestIssue))
        expect(subject).to be_an_instance_of(Array)
        expect(subject.length).not_to eq(decision_review_issues_removed.length)
      end
    end

    describe "with no removed issues" do
      subject { builder.build_issues }
      let(:decision_review_model) do
        build(:decision_review_updated, :test)
      end
      let(:decision_review_issues_removed) { decision_review_model.decision_review_issues_removed }

      it "returns an empty array" do
        expect(subject).to all(be_an_instance_of(DecisionReviewUpdated::RequestIssue))
        expect(subject).to be_an_instance_of(Array)
        expect(subject.length).to eq(0)
      end
    end
  end

  describe "#build_request_issue(issue, index)" do
    subject { builder.send(:build_request_issue, issue, index) }

    context "when the DecisionReviewUpdated::RequestIssue is built successfully" do
      it "returns a DecisionReviewUpdated::RequestIssue instance for the issue passed in" do
        expect(subject).to be_an_instance_of(DecisionReviewUpdated::RequestIssue)
      end

      it "does not raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when an exception is thrown while building the DecisionReviewUpdated::RequestIssue" do
      let(:ri_collection_builder_error) { AppealsConsumer::Error::RequestIssueBuildError }

      context "when the issue has a NIL contention_id value" do
        before do
          issue.contention_id = nil
        end

        let(:ri_collection_builder_error_msg) do
          "Failed building removed_issues from #{described_class} for "\
          "DecisionReview Claim ID: #{claim_id} Issue Index: #{index} - Issue is eligible but "\
          "has null for contention_id"
        end

        it "catches the error and raises AppealsConsumer::Error::RequestIssueBuildError with message using index as"\
          " the issue's identifier" do
          expect { subject }.to raise_error(ri_collection_builder_error, ri_collection_builder_error_msg)
        end
      end

      context "when the issue has a NOT-NIL contention_id value" do
        before do
          issue.eligibility_result = "UNKNOWN"
        end

        let(:ri_collection_builder_error_msg) do
          "Failed building removed_issues from #{described_class} for "\
          "DecisionReview Claim ID: #{claim_id} Issue Contention ID: #{issue.contention_id} - "\
          "Issue has an unrecognized eligibility_result: #{issue.eligibility_result}"
        end

        it "catches the error and raises AppealsConsumer::Error::RequestIssueBuildError with message using"\
          " contention_id as the issue's identifier" do
          expect { subject }.to raise_error(ri_collection_builder_error, ri_collection_builder_error_msg)
        end
      end
    end
  end

  describe "issue_identifier_message(issue, index)" do
    subject { builder.send(:issue_identifier_message, issue, index) }

    context "when the issue has a not-nil contention_id value" do
      it "returns 'Issue Contention ID: issue.contention_id'" do
        expect(subject).to eq("Issue Contention ID: #{issue.contention_id}")
      end
    end

    context "when the issue has a nil contention_id value" do
      before do
        issue.contention_id = nil
      end

      it "returns 'Issue Index: decision_review_issues_removed.index(issue)" do
        expect(subject).to eq("Issue Index: #{index}")
      end
    end
  end
end
