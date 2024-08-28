# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe Builders::DecisionReviewUpdated::RequestIssueBuilder do
  include_context "decision_review_updated_context"
  let(:event_id) { 34_459 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:issue) { decision_review_updated_model.decision_review_issues_created.first }
  let(:builder) { described_class.new(issue, decision_review_updated_model, bis_rating_profiles) }
  let(:bis_rating_profiles) { nil }

  describe "#self.build(issue, decision_review_model)" do
    subject { described_class.build(issue, decision_review_updated_model, bis_rating_profiles) }

    it "initializes a new RequestIssueBuilder instance for an individual DecisionReviewIssueUpdated" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "defines all instance variables for the Request Issue" do
      expect(subject.instance_variable_defined?(:@contested_issue_description)).to be_truthy
      expect(subject.instance_variable_defined?(:@contention_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_decision_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_profile_date)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_decision_issue_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@decision_date)).to be_truthy
      expect(subject.instance_variable_defined?(:@ineligible_due_to_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@is_unidentified)).to be_truthy
      expect(subject.instance_variable_defined?(:@unidentified_issue_text)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_category)).to be_truthy
      expect(subject.instance_variable_defined?(:@ineligible_reason)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_description)).to be_truthy
      expect(subject.instance_variable_defined?(:@untimely_exemption)).to be_truthy
      expect(subject.instance_variable_defined?(:@untimely_exemption_notes)).to be_truthy
      expect(subject.instance_variable_defined?(:@vacols_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@vacols_sequence_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@benefit_type)).to be_truthy
      expect(subject.instance_variable_defined?(:@closed_at)).to be_truthy
      expect(subject.instance_variable_defined?(:@closed_status)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_diagnostic_code)).to be_truthy
      expect(subject.instance_variable_defined?(:@ramp_claim_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@rating_issue_associated_at)).to be_truthy
      expect(subject.instance_variable_defined?(:@type)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_bgs_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_bgs_source)).to be_truthy
    end

    it "returns the Request Issue" do
      expect(subject).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
    end
  end

  describe "#initialize(issue, decision_review_model)" do
    it "initializes a decision_review_model instance variable" do
      expect(builder.decision_review_model).to be_an_instance_of(Transformers::DecisionReviewUpdated)
    end

    it "initializes an issue instance variable" do
      expect(builder.issue).to be_an_instance_of(DecisionReviewIssueUpdated)
    end

    it "initializes a new Request Issue instance" do
      expect(builder.request_issue).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
    end

    it "initializes an instance variable @bis_rating_profile" do
      expect(builder.instance_variable_defined?(:@bis_rating_profiles)).to eq(true)
    end
  end
end
