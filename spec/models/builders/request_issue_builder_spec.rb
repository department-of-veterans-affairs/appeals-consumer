# frozen_string_literal: true

describe Builders::RequestIssueBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:decision_review_issues) { decision_review_created.decision_review_issues }
  let(:builder) { described_class.new }

  describe "#build" do
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
    let(:request_issue) { described_class.new.request_issue }

    it "initializes a new RequestIssueBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new RequestIssue object" do
      expect(request_issue).to be_an_instance_of(RequestIssue)
    end
  end

  describe "#assign_attributes(decision_review_created)" do
    it "calls private methods" do
      decision_review_issues.each do |issue|
        allow(builder).to receive(:calculate_contested_issue_description)
        allow(builder).to receive(:assign_contention_reference_id)
        allow(builder).to receive(:assign_contested_rating_decision_reference_id)
        allow(builder).to receive(:assign_contested_rating_issue_reference_id)
        allow(builder).to receive(:assign_contested_rating_issue_profile_date)
        allow(builder).to receive(:assign_contested_decision_issue_id)
        allow(builder).to receive(:assign_decision_date)
        allow(builder).to receive(:calculate_ineligible_due_to_id)
        allow(builder).to receive(:calculate_ineligible_reason)
        allow(builder).to receive(:assign_is_unidentified)
        allow(builder).to receive(:calculate_unidentified_issue_text)
        allow(builder).to receive(:calculate_nonrating_issue_category)
        allow(builder).to receive(:calculate_nonrating_issue_description)
        allow(builder).to receive(:assign_untimely_exemption)
        allow(builder).to receive(:assign_untimely_exemption_notes)
        allow(builder).to receive(:assign_vacols_id)
        allow(builder).to receive(:assign_vacols_sequence_id)

        builder.assign_attributes(issue)

        expect(builder).to have_received(:calculate_contested_issue_description).with(issue)
        expect(builder).to have_received(:assign_contention_reference_id).with(issue)
        expect(builder).to have_received(:assign_contested_rating_decision_reference_id).with(issue)
        expect(builder).to have_received(:assign_contested_rating_issue_profile_date).with(issue)
        expect(builder).to have_received(:assign_contested_rating_issue_reference_id).with(issue)
        expect(builder).to have_received(:assign_contested_decision_issue_id).with(issue)
        expect(builder).to have_received(:assign_decision_date).with(issue)
        expect(builder).to have_received(:calculate_ineligible_due_to_id).with(issue)
        expect(builder).to have_received(:calculate_ineligible_reason).with(issue)
        expect(builder).to have_received(:assign_is_unidentified).with(issue)
        expect(builder).to have_received(:calculate_unidentified_issue_text).with(issue)
        expect(builder).to have_received(:calculate_nonrating_issue_category).with(issue)
        expect(builder).to have_received(:calculate_nonrating_issue_description).with(issue)
        expect(builder).to have_received(:assign_untimely_exemption).with(issue)
        expect(builder).to have_received(:assign_untimely_exemption_notes).with(issue)
        expect(builder).to have_received(:assign_vacols_id).with(issue)
        expect(builder).to have_received(:assign_vacols_sequence_id).with(issue)
      end
    end
  end
end
