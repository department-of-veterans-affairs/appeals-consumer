# frozen_string_literal: true

describe Veteran do
  let(:veteran) { build(:veteran) }

  it "allows reader and writer access for attributes" do
    expect(veteran.participant_id).to eq("123456789")
    expect(veteran.bgs_last_synced_at).to eq(nil)
    expect(veteran.date_of_death).to eq(Date.new(2018, 1, 1))
    expect(veteran.name_suffix).to eq(nil)
    expect(veteran.ssn).to eq("963852741")
    expect(veteran.file_number).to eq("963852741")
    expect(veteran.first_name).to eq("John")
    expect(veteran.middle_name).to eq("Russell")
    expect(veteran.last_name).to eq("Smith")
  end
end
