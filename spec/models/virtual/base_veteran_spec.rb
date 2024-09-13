# frozen_string_literal: true

describe BaseVeteran do
  let(:veteran) { build(:veteran) }

  it "allows reader and writer access for attributes" do
    expect(veteran).to respond_to(:participant_id)
    expect(veteran).to respond_to(:bgs_last_synced_at)
    expect(veteran).to respond_to(:date_of_death)
    expect(veteran).to respond_to(:name_suffix)
    expect(veteran).to respond_to(:ssn)
    expect(veteran).to respond_to(:file_number)
    expect(veteran).to respond_to(:first_name)
    expect(veteran).to respond_to(:middle_name)
    expect(veteran).to respond_to(:last_name)
  end
end
