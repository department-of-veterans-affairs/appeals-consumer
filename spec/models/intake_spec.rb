# frozen_string_literal: true

describe Intake do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  let(:intake) { build(:intake) }

  it "allows reader and writer access for attributes" do
    expect(intake.started_at).to eq(Time.now.utc - 1.minute)
    expect(intake.completion_started_at).to eq(Time.now.utc)
    expect(intake.completed_at).to eq(Time.now.utc)
    expect(intake.completion_status).to eq("success")
    expect(intake.type).to eq("HigherLevelReviewIntake")
  end
end
