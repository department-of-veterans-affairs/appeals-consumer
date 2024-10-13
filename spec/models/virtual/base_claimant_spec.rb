# frozen_string_literal: true

describe BaseClaimant do
  let(:claimant) { build(:claimant) }

  it "allows reader and writer access for attributes" do
    expect(claimant).to respond_to(:payee_code)
    expect(claimant).to respond_to(:type)
    expect(claimant).to respond_to(:participant_id)
    expect(claimant).to respond_to(:name_suffix)
    expect(claimant).to respond_to(:ssn)
    expect(claimant).to respond_to(:date_of_birth)
    expect(claimant).to respond_to(:first_name)
    expect(claimant).to respond_to(:middle_name)
    expect(claimant).to respond_to(:last_name)
    expect(claimant).to respond_to(:email)
  end
end
