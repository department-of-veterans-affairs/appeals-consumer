# frozen_string_literal: true

describe Builders::DecisionReviewCreated::RequestIssueCollectionBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:decision_review_issues) { decision_review_created.decision_review_issues }
  let(:request_issues) { described_class.build(decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let(:index) { decision_review_issues.index(issue) }
  let(:issue) { decision_review_issues.first }
  let(:claim_id) { decision_review_created.claim_id }

  describe "#self.build(decision_review_created)" do
    it "initializes an instance of Builders::DecisionReviewCreated::RequestIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(Builders::DecisionReviewCreated::RequestIssueCollectionBuilder)
    end

    it "returns an array of DecisionReviewCreated::RequestIssue(s) for every non-'CONTESTED' issue in the "\
    "decision_review_issues array" do
      expect(request_issues.count).to eq(decision_review_issues.count)
      expect(request_issues).to all(be_an_instance_of(DecisionReviewCreated::RequestIssue))
    end
  end

  describe "#initialize(decision_review_created)" do
    it "initializes a new instance of Builders::DecisionReviewCreated::RequestIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(described_class)
    end
  end

  describe "#build_issues" do
    subject { builder.build_issues }
    let(:decision_review_created) do
      build(:decision_review_created, :ineligible_nonrating_hlr_contested_with_additional_issue)
    end

    it "maps valid decision_review_issues into an array of DecisionReviewCreated::RequestIssue(s)" do
      expect(subject).to all(be_an_instance_of(DecisionReviewCreated::RequestIssue))
      expect(subject).to be_an_instance_of(Array)
    end
  end

  describe "#valid_issues" do
    subject { builder.send(:valid_issues) }

    context "when there aren't any issues after removing 'CONTESTED' issues" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_nonrating_hlr_contested) }
      let(:error) { AppealsConsumer::Error::RequestIssueCollectionBuildError }
      let(:error_msg) do
        "Failed building from Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for "\
        "DecisionReviewCreated Claim ID: #{decision_review_created.claim_id} does not contain any "\
        "valid issues after removing 'CONTESTED' ineligible issues"
      end

      it "raises AppealsConsumer::Error::RequestIssueCollectionBuildError with message" do
        expect { subject }.to raise_error(error, error_msg)
      end
    end

    context "when there are still issues after removing 'CONTESTED' issues" do
      let(:decision_review_created) do
        build(:decision_review_created, :ineligible_nonrating_hlr_contested_with_additional_issue)
      end

      it "returns an array of valid DecisionReviewIssue(s)" do
        expect(subject).to all(be_an_instance_of(DecisionReviewIssue))
        expect(subject.count).to eq(decision_review_issues.count - 1)
      end
    end
  end

  describe "#handle_no_issues_after_removing_contested" do
    subject { builder.send(:handle_no_issues_after_removing_contested) }
    let(:error) { AppealsConsumer::Error::RequestIssueCollectionBuildError }
    let(:error_msg) do
      "Failed building from Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for "\
      "DecisionReviewCreated Claim ID: #{claim_id} does not contain any valid issues after "\
      "removing 'CONTESTED' ineligible issues"
    end

    it "raises error AppealsConsumer::Error::RequestIssueCollectionBuildError with message" do
      expect { subject }.to raise_error(error, error_msg)
    end
  end

  describe "#remove_ineligible_contested_issues" do
    subject { builder.send(:remove_ineligible_contested_issues) }
    let(:decision_review_created) do
      build(:decision_review_created, :ineligible_nonrating_hlr_contested_with_additional_issue)
    end
    let(:contested) { described_class::CONTESTED }

    it "removes decision_review_issues that contains an eligibility_result of 'CONTESTED'" do
      expect(subject.count).to eq(decision_review_issues.count - 1)
      expect(subject.any? { |issue| issue.eligibility_result == contested }).to eq false
    end
  end

  describe "#build_request_issue(issue, index)" do
    subject { builder.send(:build_request_issue, issue, index) }

    context "when the DecisionReviewCreated::RequestIssue is built successfully" do
      it "returns a DecisionReviewCreated::RequestIssue instance for the issue passed in" do
        expect(subject).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
      end

      it "does not raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when an exception is thrown while building the DecisionReviewCreated::RequestIssue" do
      let(:ri_collection_builder_error) { AppealsConsumer::Error::RequestIssueBuildError }

      context "when the issue has a NIL contention_id value" do
        before do
          issue.contention_id = nil
        end

        let(:ri_collection_builder_error_msg) do
          "Failed building from Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for "\
          "DecisionReviewCreated Claim ID: #{claim_id} Issue Index: #{index} - Issue is eligible but "\
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
          "Failed building from Builders::DecisionReviewCreated::RequestIssueCollectionBuilder for "\
          "DecisionReviewCreated Claim ID: #{claim_id} Issue Contention ID: #{issue.contention_id} - "\
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

      it "returns 'Issue Index: decision_review_issues.index(issue)" do
        expect(subject).to eq("Issue Index: #{index}")
      end
    end
  end
end
