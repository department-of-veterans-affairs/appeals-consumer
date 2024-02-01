# frozen_string_literal: true

describe Builders::RequestIssueBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:decision_review_issues) { decision_review_created.decision_review_issues }
  let(:issue) { decision_review_issues.first }
  let(:builder) { described_class.new(issue, decision_review_created) }

  describe "#build" do
    subject(:request_issues) { described_class.build(decision_review_created) }
    it "a RequestIssueBuilder instance is initialized for every issue in the decision_review_issues array" do
      expect(described_class).to receive(:new).twice.and_call_original
      request_issues
    end

    it "returns an array with a RequestIssue object for every issue in the decision_review_issues array" do
      expect(request_issues.count).to eq(decision_review_issues.count)
      expect(request_issues).to all(be_an_instance_of(RequestIssue))
    end
  end

  describe "#initialize(issue, deicision_review_created)" do
    let(:request_issue) { described_class.new(issue, decision_review_created).request_issue }

    it "initializes a new RequestIssueBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new RequestIssue object" do
      expect(request_issue).to be_an_instance_of(RequestIssue)
    end

    it "assigns issue to the DecisionReviewIssue object passed in" do
      expect(builder.issue).to be_an_instance_of(DecisionReviewIssue)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      allow(builder).to receive(:calculate_benefit_type)
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
      allow(builder).to receive(:calculate_closed_at)
      allow(builder).to receive(:calculate_closed_status)
      allow(builder).to receive(:assign_contested_rating_issue_diagnostic_code)
      allow(builder).to receive(:calculate_ramp_claim_id)
      allow(builder).to receive(:calculate_rating_issue_associated_at)
      allow(builder).to receive(:calculate_type)
      allow(builder).to receive(:assign_nonrating_issue_bgs_id)

      builder.assign_attributes

      expect(builder).to have_received(:calculate_benefit_type)
      expect(builder).to have_received(:calculate_contested_issue_description)
      expect(builder).to have_received(:assign_contention_reference_id)
      expect(builder).to have_received(:assign_contested_rating_decision_reference_id)
      expect(builder).to have_received(:assign_contested_rating_issue_profile_date)
      expect(builder).to have_received(:assign_contested_rating_issue_reference_id)
      expect(builder).to have_received(:assign_contested_decision_issue_id)
      expect(builder).to have_received(:assign_decision_date)
      expect(builder).to have_received(:calculate_ineligible_due_to_id)
      expect(builder).to have_received(:calculate_ineligible_reason)
      expect(builder).to have_received(:assign_is_unidentified)
      expect(builder).to have_received(:calculate_unidentified_issue_text)
      expect(builder).to have_received(:calculate_nonrating_issue_category)
      expect(builder).to have_received(:calculate_nonrating_issue_description)
      expect(builder).to have_received(:assign_untimely_exemption)
      expect(builder).to have_received(:assign_untimely_exemption_notes)
      expect(builder).to have_received(:assign_vacols_id)
      expect(builder).to have_received(:assign_vacols_sequence_id)
      expect(builder).to have_received(:calculate_closed_at)
      expect(builder).to have_received(:calculate_closed_status)
      expect(builder).to have_received(:assign_contested_rating_issue_diagnostic_code)
      expect(builder).to have_received(:calculate_ramp_claim_id)
      expect(builder).to have_received(:calculate_rating_issue_associated_at)
      expect(builder).to have_received(:calculate_type)
      expect(builder).to have_received(:assign_nonrating_issue_bgs_id)
    end
  end
end
