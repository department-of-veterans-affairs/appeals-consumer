# frozen_string_literal: true

describe Intake do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.started_at = Time.now.utc - 1.minute
      subject.completion_started_at = Time.now.utc
      subject.completed_at = Time.now.utc
      subject.completion_status = "success"
      subject.type = "HigherLevelReviewIntake"

      expect(subject.started_at).to eq(Time.now.utc - 1.minute)
      expect(subject.completion_started_at).to eq(Time.now.utc)
      expect(subject.completed_at).to eq(Time.now.utc)
      expect(subject.completion_status).to eq("success")
      expect(subject.type).to eq("HigherLevelReviewIntake")
    end
  end
end
