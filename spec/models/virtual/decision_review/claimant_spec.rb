# frozen_string_literal: true

describe DecisionReview::Claimant do
  let(:claimant) { build(:claimant) }

  it "allows reader and writer access for attributes" do
    expect(claimant.payee_code).to eq("00")
    expect(claimant.type).to eq("VeteranClaimant")
    expect(claimant.participant_id).to eq("123456789")
    expect(claimant.name_suffix).to eq(nil)
    expect(claimant.ssn).to eq("987654321")
    expect(claimant.date_of_birth).to eq(Date.new(2022, 1, 1))
    expect(claimant.first_name).to eq("John")
    expect(claimant.middle_name).to eq("Russell")
    expect(claimant.last_name).to eq("Smith")
    expect(claimant.email).to eq("johnrsmith@gmail.com")
  end
end
