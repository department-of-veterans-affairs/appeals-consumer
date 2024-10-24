# frozen_string_literal: true

describe PersonUpdated::Person do
  let(:person) { build(:person) }

  it "allows reader and writer access for attributes" do
    expect(person.participant_id).to eq("123456789")
    expect(person.name_suffix).to eq(nil)
    expect(person.ssn).to eq("963852741")
    expect(person.first_name).to eq("John")
    expect(person.middle_name).to eq("Russell")
    expect(person.last_name).to eq("Smith")
    expect(person.email_address).to eq("email@email.com")
    expect(person.date_of_birth).to eq(Date.new(1969, 1, 1))
    expect(person.date_of_death).to eq(Date.new(2022, 1, 1))
    expect(person.file_number).to eq("123456789")
    expect(person.is_veteran).to eq(false)
  end
end
