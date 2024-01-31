# frozen_string_literal: true

describe Builders::RequestIssueBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    let!(:decision_review_issues) { decision_review_created.decision_review_issues }
    subject(:request_issues) { described_class.build(decision_review_issues) }

    it "a RequestIssueBuilder instance is initialized for every issue in the decision_review_issues array" do
      expect(described_class).to receive(:new).twice.and_call_original
      request_issues
    end

    it "returns an array with a RequestIssue object for every issue in the decision_review_issues array" do
      expect(request_issues.count).to eq(decision_review_issues.count)
      expect(request_issues).to all(be_an_instance_of(RequestIssue))
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:request_issue) { described_class.new.request_issue }

    it "initializes a new RequestIssueBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new RequestIssue object" do
      expect(request_issue).to be_an_instance_of(RequestIssue)
    end
  end
end
