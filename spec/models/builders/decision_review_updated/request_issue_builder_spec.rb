# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe Builders::DecisionReviewUpdated::RequestIssueBuilder do
  include_context "decision_review_updated_context"
  let(:event_id) { 34_459 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:issue) { decision_review_updated_model.decision_review_issues_updated.first }
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
      expect(subject.instance_variable_defined?(:@decision_review_issue_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@edited_description)).to be_truthy
    end

    it "returns the Request Issue" do
      expect(subject).to be_an_instance_of(DecisionReviewUpdated::RequestIssue)
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
      expect(builder.request_issue).to be_an_instance_of(DecisionReviewUpdated::RequestIssue)
    end

    it "initializes an instance variable @bis_rating_profile" do
      expect(builder.instance_variable_defined?(:@bis_rating_profiles)).to eq(true)
    end
  end

  describe "#assign_methods" do
    it "calls assign methods" do
      expect(builder).to receive(:assign_original_caseflow_request_issue_id)
      expect(builder).to receive(:assign_contested_rating_decision_reference_id)
      expect(builder).to receive(:assign_contested_rating_issue_reference_id)
      expect(builder).to receive(:assign_contested_decision_issue_id)
      expect(builder).to receive(:assign_untimely_exemption)
      expect(builder).to receive(:assign_untimely_exemption_notes)
      expect(builder).to receive(:assign_vacols_id)
      expect(builder).to receive(:assign_vacols_sequence_id)
      expect(builder).to receive(:assign_nonrating_issue_bgs_id)
      expect(builder).to receive(:assign_type)
      expect(builder).to receive(:assign_decision_review_issue_id)
      expect(builder).to receive(:assign_veteran_participant_id)

      builder.send(:assign_methods)
    end
  end

  describe "#calculate_methods" do
    it "calls calculate methods" do
      expect(builder).to receive(:calculate_edited_description)
      expect(builder).to receive(:calculate_contention_reference_id)
      expect(builder).to receive(:calculate_benefit_type)
      expect(builder).to receive(:calculate_contested_issue_description)
      expect(builder).to receive(:calculate_contested_rating_issue_profile_date)
      expect(builder).to receive(:calculate_decision_date)
      expect(builder).to receive(:calculate_ineligible_due_to_id)
      expect(builder).to receive(:calculate_ineligible_reason)
      expect(builder).to receive(:calculate_unidentified_issue_text)
      expect(builder).to receive(:calculate_nonrating_issue_category)
      expect(builder).to receive(:calculate_nonrating_issue_description)
      expect(builder).to receive(:calculate_closed_at)
      expect(builder).to receive(:calculate_closed_status)
      expect(builder).to receive(:calculate_contested_rating_issue_diagnostic_code)
      expect(builder).to receive(:calculate_ramp_claim_id)
      expect(builder).to receive(:calculate_rating_issue_associated_at)
      expect(builder).to receive(:calculate_is_unidentified)
      expect(builder).to receive(:calculate_nonrating_issue_bgs_source)

      builder.send(:calculate_methods)
    end
  end

  describe "#assign_veteran_participant_id" do
    subject { builder.send(:assign_veteran_participant_id) }
    it "assigns the veteran's participant id to the value passed by the event" do
      expect(subject).to eq(decision_review_updated_model.veteran_participant_id)
    end
  end

  describe "#assign_decision_review_issue_id" do
    subject { builder.send(:assign_decision_review_issue_id) }

    context "when the issue has a decision_review_issue_id value" do
      it "assigns the issue's decision_review_issue_id to that value" do
        issue.decision_review_issue_id = 2100
        expect(subject).to eq(issue.decision_review_issue_id)
      end
    end

    context "when the issue does not have a decision_review_issue_id value" do
      it "assigns the issue's decision_review_issue_id to nil" do
        issue.decision_review_issue_id = nil
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_closed_at" do
    subject { builder.send(:calculate_closed_at) }
    let(:update_time_converted_to_timestamp_ms) do
      builder.update_time_converted_to_timestamp_ms
    end
    let(:closed_at) { builder.request_issue.closed_at }
    let(:closed_status) { builder.request_issue.closed_status }

    context "when the issue is ineligible" do
      it "sets the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:ineligible?).and_return(true)
        allow(builder).to receive(:withdrawn?).and_return(false)
        allow(builder).to receive(:removed?).and_return(false)
        expect(subject).to eq(update_time_converted_to_timestamp_ms)
      end
    end

    context "when the issue is withdrawn" do
      it "sets the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:withdrawn?).and_return(true)
        allow(builder).to receive(:ineligible?).and_return(false)
        allow(builder).to receive(:removed?).and_return(false)
        expect(subject).to eq(update_time_converted_to_timestamp_ms)
      end
    end

    context "when the issue is removed" do
      it "sets the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:removed?).and_return(true)
        allow(builder).to receive(:ineligible?).and_return(false)
        allow(builder).to receive(:withdrawn?).and_return(false)
        expect(subject).to eq(update_time_converted_to_timestamp_ms)
      end
    end

    context "when the issue is eligible" do
      it "DOES NOT set the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:ineligible?).and_return(false)
        expect(subject).to eq(nil)
        expect(closed_at).to eq(nil)
        expect(closed_status).to eq(nil)
      end
    end

    context "when the issue is NOT withdrawn" do
      it "DOES NOT set the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:withdrawn?).and_return(false)
        expect(subject).to eq(nil)
        expect(closed_at).to eq(nil)
        expect(closed_status).to eq(nil)
      end
    end

    context "when the issue is NOT removed" do
      it "DOES NOT set the Request Issue's closed_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:removed?).and_return(false)
        expect(subject).to eq(nil)
        expect(closed_at).to eq(nil)
        expect(closed_status).to eq(nil)
      end
    end
  end

  describe "#calculate_edited_description" do
    subject { builder.send(:calculate_edited_description) }

    context "when the issue has an edited description" do
      it "assigns the issue's edited_description to prior_decision_text" do
        allow(builder).to receive(:edited_description?).and_return(true)
        expect(subject).to eq(issue.prior_decision_text)
      end
    end

    context "when the issue does NOT have an edited_description" do
      it "does NOT assign a value to the issue's edited_description" do
        allow(builder).to receive(:edited_description?).and_return(false)
        expect(subject).to be_nil
      end
    end
  end

  describe "#calculate_rating_issue_associated_at" do
    subject { builder.send(:calculate_rating_issue_associated_at) }
    let(:update_time_converted_to_timestamp_ms) do
      builder.update_time_converted_to_timestamp_ms
    end

    context "when populating eligible rating issues" do
      it "sets the Request Issue's rating_issue_associated_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:rating?).and_return(true)
        allow(builder).to receive(:eligible?).and_return(true)

        expect(subject).to eq(update_time_converted_to_timestamp_ms)
      end
    end

    context "when populating ineligible rating issues" do
      it "DOES NOT set the Request Issue's rating_issue_associated_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:rating?).and_return(true)
        allow(builder).to receive(:eligible?).and_return(false)

        expect(subject).to eq(nil)
      end
    end

    context "when populating eligible nonrating issues" do
      it "DOES NOT set the Request Issue's rating_issue_associated_at to update_time_converted_to_timestamp_ms" do
        allow(builder).to receive(:rating?).and_return(false)
        allow(builder).to receive(:eligible?).and_return(true)

        expect(subject).to eq(nil)
      end
    end
  end

  describe "#_edited_description?" do
    subject { builder.send(:edited_description?) }

    context "when prior_decision_text_changed? and updated_contention? evaluate to true" do
      it "returns true" do
        allow(builder).to receive(:prior_decision_text_changed?).and_return(true)
        allow(builder).to receive(:updated_contention?).and_return(true)
        expect(subject).to eq(true)
      end
    end

    context "when prior_decision_text_changed? evaluates to true and updated_contention? evaluates to false" do
      it "returns false" do
        allow(builder).to receive(:prior_decision_text_changed?).and_return(true)
        allow(builder).to receive(:updated_contention?).and_return(false)
        expect(subject).to eq(false)
      end
    end

    context "when prior_decision_text_changed? evaluates to false and updated_contention? evaluates to true" do
      it "returns false" do
        allow(builder).to receive(:prior_decision_text_changed?).and_return(false)
        allow(builder).to receive(:updated_contention?).and_return(true)
        expect(subject).to eq(false)
      end
    end
  end

  describe "#_prior_decision_text_changed?" do
    subject { builder.send(:prior_decision_text_changed?) }

    context "when the issues reason_for_contention_action is 'PRIOR_DECISION_TEXT_CHANGED'" do
      it "returns true" do
        issue.reason_for_contention_action = "PRIOR_DECISION_TEXT_CHANGED"
        expect(subject).to eq(true)
      end
    end

    context "when the issues reason_for_contention_action is NOT 'PRIOR_DECISION_TEXT_CHANGED'" do
      it "returns false" do
        issue.reason_for_contention_action = "NEW_ELIGIBLE_ISSUE"
        expect(subject).to eq(false)
      end
    end

    context "when the issues reason_for_contention_action is nil" do
      it "returns false" do
        issue.reason_for_contention_action = nil
        expect(subject).to eq(false)
      end
    end
  end

  describe "#_updated_contention?" do
    subject { builder.send(:updated_contention?) }

    context "when the isses contention action is 'UPDATE_CONTENTION'" do
      it "returns true" do
        issue.contention_action = "UPDATE_CONTENTION"
        expect(subject).to eq(true)
      end
    end

    context "when the isses contention action is NOT 'UPDATE_CONTENTION'" do
      it "returns false" do
        issue.contention_action = "NONE"
        expect(subject).to eq(false)
      end
    end

    context "when the isses contention action is nil" do
      it "returns false" do
        issue.contention_action = nil
        expect(subject).to eq(false)
      end
    end
  end
end
