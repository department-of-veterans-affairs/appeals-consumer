# frozen_string_literal: true

require "shared_context/person_updated_context"

describe Transformers::PersonUpdated do
  subject(:person_updated) { described_class.new(event_id, message_payload) }

  include_context "person_updated_context"

  let(:event_id) { 13 }

  context "when valid" do
    describe "#initialize" do
      it "sets the event id" do
        expect(person_updated.event_id).to eq(13)
      end

      it "validates the message_payload" do
        expect { person_updated }.not_to raise_error
      end

      it "allows string participant_id" do
        subject.participant_id = message_payload["participant_id"].to_s
        expect(subject).to be_valid
      end

      it "when participant_id is a integer it raises ArgumentError" do
        subject.participant_id = message_payload["participant_id"].to_i
        expect { subject.valid? }.to raise_error(ArgumentError)
      end

      it "when participant_id is nil it raises ArgumentError" do
        subject.participant_id = nil
        expect { subject.valid? }.to raise_error(ArgumentError)
      end

      it "sets the instance variables for PersonUpdated" do
        expect(subject.name_suffix).to eq(message_payload["name_suffix"])
        expect(subject.social_security_number).to eq(message_payload["social_security_number"])
        expect(subject.first_name).to eq(message_payload["first_name"])
        expect(subject.middle_name).to eq(message_payload["middle_name"])
        expect(subject.last_name).to eq(message_payload["last_name"])
        expect(subject.date_of_birth).to eq(message_payload["date_of_birth"])
        expect(subject.date_of_death).to eq(message_payload["date_of_death"])
        expect(subject.file_number).to eq(message_payload["file_number"])
        expect(subject.veteran_indicator).to eq(message_payload["veteran_indicator"])
      end
    end
  end
end
