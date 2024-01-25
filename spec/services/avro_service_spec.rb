# frozen_string_literal: true

RSpec.describe AvroService, type: :service do
  describe "instance methods" do
    before do
      ClimateControl.modify SCHEMA_REGISTRY_URL: "http://localhost" do
        subject { AvroService.new }
      end
    end

    context "#initialize" do
      it "should return a non-nil AvroTurf::Messaging instance on initialize" do
        expect(subject.instance_variable_get(:@avro).nil?).to eq false
      end
    end

    # rubocop:disable Layout/LineLength
    context "#encode and #decode" do
      let(:avro_turf_messager) { double("avro_turf_messager") }
      sample_encoded_message = "Obj\u0001\u0004\u0014avro.codec\bnull\u0016avro.schema\x9E\u0005{\"type\":\"record\",\"name\":\"person\",\"doc\":\"just a person\",\"fields\":[{\"name\":\"full_name\",\"type\":\"string\",\"doc\":\"full name of person\"},{\"name\":\"age\",\"type\":\"int\",\"doc\":\"age of person\"},{\"name\":\"computer\",\"type\":{\"type\":\"record\",\"name\":\"computer\",\"doc\":\"my work computer\",\"fields\":[{\"name\":\"brand\",\"type\":\"string\",\"doc\":\"name of brand\"}]}}]}\u0000\xE7z\\\x9C\xE4CJݦ\u0003\xAB[+״\xB0\u0002\u0014\bJohnd\u0006mac\xE7z\\\x9C\xE4CJݦ\u0003\xAB[+״\xB0"
      sample_decoded_message = { "full_name" => "John", "age" => 50, "computer" => { "brand" => "mac" } }

      it "should be able to encode using an avro" do
        allow(avro_turf_messager).to receive(:encode).with(sample_decoded_message, subject: "person", version: 1, validate: true).and_return(sample_encoded_message)
        subject.instance_variable_set(:@avro, avro_turf_messager)
        expect(subject.encode(sample_decoded_message, "person")).to eq sample_encoded_message
      end

      it "should be able to decode using an avro" do
        allow(avro_turf_messager).to receive(:decode_message).with(sample_encoded_message).and_return(sample_decoded_message)
        subject.instance_variable_set(:@avro, avro_turf_messager)
        expect(subject.decode(sample_encoded_message)).to eq sample_decoded_message
      end
    end
    # rubocop:enable Layout/LineLength
  end
end
