# frozen_string_literal: true

describe ExternalApi::CaseflowService do
  let(:base_url) { "http://caseflow.test/api/events/v1/" }
  let(:error_message) { "Failed for claim_id: #{dto_builder.payload['claim_id']}" }
  let(:error_code) { "HTTP code: 500" }
  let(:dto_builder) do
    instance_double(
      "DtoBuilder",
      payload: { "claim_id" => "123" },
      vet_ssn: "1234-56-789",
      vet_file_number: "12345",
      vet_first_name: "John",
      vet_last_name: "Doe",
      vet_middle_name: "Michael",
      claimant_ssn: "1234-56-789",
      claimant_dob: "01-01-01",
      claimant_first_name: "John",
      claimant_last_name: "Doe",
      claimant_middle_name: "Michael",
      claimant_email: "johndoe@email.com"
    )
  end
  let(:headers) do
    {
      "AUTHORIZATION" => "Token token=secret",
      "CSS-ID" => RequestStore[:current_user][:css_id],
      "STATION-ID" => RequestStore[:current_user][:station_id],
      "X-VA-Vet-SSN" => "1234-56-789",
      "X-VA-File-Number" => "12345",
      "X-VA-Vet-First-Name" => "John",
      "X-VA-Vet-Last-Name" => "Doe",
      "X-VA-Vet-Middle-Name" => "Michael",
      "X-VA-Claimant-SSN" => "1234-56-789",
      "X-VA-Claimant-DOB" => "01-01-01",
      "X-VA-Claimant-First-Name" => "John",
      "X-VA-Claimant-Last-Name" => "Doe",
      "X-VA-Claimant-Middle-Name" => "Michael",
      "X-VA-Claimant-Email" => "johndoe@email.com"
    }
  end

  before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
    RequestStore.store[:current_user] = {
      css_id: "css_id",
      station_id: "station_id"
    }
    allow(Rails.application.config).to receive(:caseflow_url).and_return("http://caseflow.test")
    allow(Rails.application.config).to receive(:caseflow_key).and_return("secret")
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CSS_ID").and_return("css_id")
    allow(ENV).to receive(:[]).with("STATION_ID").and_return("station_id")
  end

  after(:each) do
    WebMock.allow_net_connect!
    RequestStore.clear!
  end

  describe ".establish_decision_review_created_records_from_event!" do
    let(:endpoint) { "#{base_url}decision_review_created" }
    let(:drc_dto_builder) { dto_builder }

    context "when the request is successfull" do
      before do
        stub_request(:post, endpoint)
          .with(body: drc_dto_builder.payload.to_json, headers: headers)
          .to_return(status: 200, body: '{"success": true}', headers: {})
      end

      it "returns the HTTP status code" do
        response = described_class.establish_decision_review_created_records_from_event!(drc_dto_builder)
        expect(response.code).to eq(200)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        described_class.establish_decision_review_created_records_from_event!(drc_dto_builder)
      end
    end

    context "when the request fails with an error code" do
      before do
        stub_request(:post, endpoint)
          .with(body: drc_dto_builder.payload.to_json, headers: headers)
          .to_return(status: 500, body: '{"error": "Internal Server Error"}', headers: {})
      end

      it "raises a ClientRequestError with the proper message and code" do
        expect { described_class.establish_decision_review_created_records_from_event!(drc_dto_builder) }
          .to raise_error(AppealsConsumer::Error::ClientRequestError) do |error|
          expect(error.code).to eq(500)
          expect(error.message).to include(error_message, error_code)
        end
      end
    end
  end

  describe ".establish_decision_review_created_event_error!" do
    let(:event_id) { "123" }
    let(:errored_claim_id) { "456" }
    let(:error_message) { "Sample error message" }
    let(:endpoint) { "#{base_url}decision_review_created_error" }
    let(:headers) { { "AUTHORIZATION" => "Token token=secret", "CSS-ID" => "css_id", "STATION-ID" => "station_id" } }

    context "when the request is successful" do
      before do
        payload = { event_id: event_id, errored_claim_id: errored_claim_id, error: error_message }.to_json
        stub_request(:post, endpoint)
          .with(body: payload, headers: headers)
          .to_return(status: 200, body: '{"success": true}', headers: {})
      end

      it "returns a successful response object" do
        response = described_class.establish_decision_review_created_event_error!(
          event_id,
          errored_claim_id,
          error_message
        )
        expect(response.code).to eq(200)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        described_class.establish_decision_review_created_event_error!(
          event_id,
          errored_claim_id,
          error_message
        )
      end
    end
  end

  describe "#edit_records_from_decision_review_updated_event!" do
    let(:endpoint) { "#{base_url}decision_review_updated" }
    let(:decision_review_updated_dto_builder) { dto_builder }

    context "when the request is successful" do
      before do
        stub_request(:post, endpoint)
          .with(body: decision_review_updated_dto_builder.payload.to_json)
          .to_return(status: 200, body: '{"success": true}', headers: {})
      end

      it "returns the HTTP status code" do
        response = described_class.edit_records_from_decision_review_updated_event!(decision_review_updated_dto_builder)
        expect(response.code).to eq(200)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        described_class.edit_records_from_decision_review_updated_event!(decision_review_updated_dto_builder)
      end
    end

    context "when the request fails with an error code" do
      before do
        stub_request(:post, endpoint)
          .with(body: decision_review_updated_dto_builder.payload.to_json)
          .to_return(status: 500, body: '{"error": "Internal Server Error"}', headers: {})
      end

      it "raises a ClientRequestError with the proper message and code" do
        expect { described_class.edit_records_from_decision_review_updated_event!(decision_review_updated_dto_builder) }
          .to raise_error(AppealsConsumer::Error::ClientRequestError) do |error|
          expect(error.code).to eq(500)
          expect(error.message).to include(error_message, error_code)
        end
      end
    end
  end
end
