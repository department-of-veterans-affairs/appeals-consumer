# frozen_string_literal: true

describe AvroDeserializerService do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  subject(:avro_deserializer) { described_class.new }

  let(:camelcase_payload) do
    snakecase_payload.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  let(:snakecase_payload) do
    {
      claim_id: 1_234_567,
      decision_review_type: "HigherLevelReview",
      veteran_first_name: "John",
      veteran_last_name: "Smith",
      veteran_participant_id: "123456789",
      file_number: "123456789",
      claimant_participant_id: "01010101",
      ep_code: "030HLRNR",
      ep_code_category: "Rating",
      claim_received_date: Date.new(2022, 1, 1),
      claim_lifecycle_status: "RFD",
      payee_code: "00",
      modifier: "01",
      originated_from_vacols_issue: false,
      informal_conference_requested: false,
      same_station_review_requested: false,
      intake_creation_time: Time.now.utc,
      claim_creation_time: Time.now.utc,
      created_by_username: "BVADWISE101",
      created_by_station: "101",
      created_by_application: "PASYSACCTCREATE",
      decision_review_issues: [
        {
          contention_id: 123_456_789,
          associated_caseflow_request_issue_id: nil,
          unidentified: false,
          prior_rating_decision_id: nil,
          prior_non_rating_decision_id: 12,
          prior_decision_text: "service connection for tetnus denied",
          prior_decision_type: "DIC",
          prior_decision_notification_date: Date.new(2022, 1, 1),
          prior_decision_diagnostic_code: nil,
          prior_decision_rating_percentage: nil,
          eligible: true,
          eligibility_result: "ELIGIBLE",
          time_override: nil,
          time_override_reason: nil,
          contested: nil,
          soc_opt_in: nil,
          legacy_appeal_id: nil,
          legacy_appeal_issue_id: nil
        },
        {
          contention_id: 987_654_321,
          associated_caseflow_request_issue_id: nil,
          unidentified: false,
          prior_rating_decision_id: nil,
          prior_non_rating_decision_id: 13,
          prior_decision_text: "service connection for ear infection denied",
          prior_decision_type: "Basic Eligibility",
          prior_decision_notification_date: Date.new(2022, 1, 1),
          prior_decision_diagnostic_code: nil,
          prior_decision_rating_percentage: nil,
          eligible: true,
          eligibility_result: "ELIGIBLE",
          time_override: nil,
          time_override_reason: nil,
          contested: nil,
          soc_opt_in: nil,
          legacy_appeal_id: nil,
          legacy_appeal_issue_id: nil
        }
      ]
    }.deep_transform_keys!(&:to_s)
  end

  let(:avro_service) { AvroService.new }
  let(:encoded_message) { avro_service.encode(camelcase_payload, "DecisionReviewCreated") }
  let(:message) { instance_double(Karafka::Messages::Message, raw_payload: encoded_message) }
  let(:decoded_message) { avro_deserializer.send(:decode_avro_message, message) }
  let(:transformed_message_payload) { avro_deserializer.send(:transform_payload_to_snakecase, decoded_message) }

  describe "#initialize" do
    it "initializes an AvroTurf::Messaging instance with the correct arguments" do
      expect(AvroTurf::Messaging).to receive(:new).with(
        registry_url: ENV.fetch("SCHEMA_REGISTRY_URL"),
        logger: an_instance_of(AvroLoggerService)
      )
      avro_deserializer
    end
  end

  describe "#call(message)" do
    subject { avro_deserializer.call(message) }

    it "returns an instance of AvroTurf::Messaging::DecodedMessage with the decoded, snakecase message" do
      expect(subject).to be_an_instance_of(AvroTurf::Messaging::DecodedMessage)
      expect(subject.message).to eq(snakecase_payload)
    end
  end

  describe "#decode_avro_message(message)" do
    subject { avro_deserializer.send(:decode_avro_message, message) }

    it "decodes the message" do
      expect(subject.message).to eq(camelcase_payload)
    end
  end

  describe "#decode_avro_message(message)" do
    subject { avro_deserializer.send(:transform_payload_to_snakecase, decoded_message) }

    it "transforms the payload from camelcase to snakecase" do
      expect(subject).to eq(snakecase_payload)
    end
  end
end