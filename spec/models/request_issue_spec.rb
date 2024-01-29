# frozen_string_literal: true

describe RequestIssue do
  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.contested_issue_description = "service connection for migraine is denied"
      subject.contention_reference_id = "123456789"
      subject.contested_rating_decision_reference_id = nil
      subject.contested_rating_issue_profile_date = Date.new(2022, 1, 1)
      subject.contested_rating_issue_reference_id = "963852741"
      subject.contested_decision_issue_id = nil
      subject.decision_date = Date.new(2022, 2, 1)
      subject.ineligible_due_to_id = nil
      subject.ineligible_reason = nil
      subject.is_unidentified = false
      subject.unidentified_issue_text = nil
      subject.nonrating_issue_category = nil
      subject.nonrating_issue_description = nil
      subject.untimely_exemption = nil
      subject.untimely_exemption_notes = nil
      subject.vacols_id = nil
      subject.vacols_sequence_id = nil

      expect(subject.contested_issue_description).to eq("service connection for migraine is denied")
      expect(subject.contention_reference_id).to eq("123456789")
      expect(subject.contested_rating_decision_reference_id).to eq(nil)
      expect(subject.contested_rating_issue_profile_date).to eq(Date.new(2022, 1, 1))
      expect(subject.contested_rating_issue_reference_id).to eq("963852741")
      expect(subject.contested_decision_issue_id).to eq(nil)
      expect(subject.decision_date).to eq(Date.new(2022, 2, 1))
      expect(subject.ineligible_due_to_id).to eq(nil)
      expect(subject.ineligible_reason).to eq(nil)
      expect(subject.is_unidentified).to eq(false)
      expect(subject.unidentified_issue_text).to eq(nil)
      expect(subject.ineligible_due_to_id).to eq(nil)
      expect(subject.ineligible_reason).to eq(nil)
      expect(subject.nonrating_issue_category).to eq(nil)
      expect(subject.nonrating_issue_description).to eq(nil)
      expect(subject.untimely_exemption).to eq(nil)
      expect(subject.untimely_exemption_notes).to eq(nil)
      expect(subject.vacols_id).to eq(nil)
      expect(subject.vacols_sequence_id).to eq(nil)
    end
  end
end
