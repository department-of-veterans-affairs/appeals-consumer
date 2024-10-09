# frozen_string_literal: true

describe BasePerson do
  let(:person) { build(:person) }

  it "allows reader and writer access for attributes" do
    expect(person).to respond_to(:participant_id)
    expect(person).to respond_to(:date_of_birth)
    expect(person).to respond_to(:name_suffix)
    expect(person).to respond_to(:ssn)
    expect(person).to respond_to(:first_name)
    expect(person).to respond_to(:middle_name)
    expect(person).to respond_to(:last_name)
    expect(person).to respond_to(:email_address)
    expect(person).to respond_to(:file_number)
    expect(person).to respond_to(:date_of_death)
  end
end
