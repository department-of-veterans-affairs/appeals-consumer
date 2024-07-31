# frozen_string_literal: true

#  Service class for interacting with the Caseflow API, handling decision review events and errors.
class ExternalApi::CaseflowService
  include LoggerMixin
  # Base endpoint for the Caseflow API events.
  BASE_ENDPOINT = "api/events/v1/"

  class << self
    # Creates records for a new decision review based on the provided Decision Review Created DTO builder.
    # It sends a request to the Caseflow API and precesses the response.
    def establish_decision_review_created_records_from_event!(drc_dto_builder)
      payload = drc_dto_builder.payload
      headers = build_headers(drc_dto_builder)
      endpoint = "#{BASE_ENDPOINT}decision_review_created"
      response = send_caseflow_request(payload, endpoint, headers)
      parse_response(response, payload["claim_id"])
    end

    # Reports an error during decision review creation, using detailed error information.
    def establish_decision_review_created_event_error!(event_id, claim_id, error_message)
      payload = { event_id: event_id, errored_claim_id: claim_id, error: error_message }
      endpoint = "#{BASE_ENDPOINT}decision_review_created_error"
      response = send_caseflow_request(payload, endpoint)
      parse_response(response, claim_id)
    end

    # Sends request to Caseflow API and processes response.
    def edit_decision_review_updated_records_from_event!(decision_review_updated_dto_builder)
      payload = decision_review_updated_dto_builder.payload
      headers = build_headers(decision_review_updated_dto_builder)
      endpoint = "#{BASE_ENDPOINT}decision_review_updated"
      response = send_caseflow_request(payload, endpoint, headers)
      parse_response(response, payload["claim_id"])
    end

    private

    # Sends a request to the Caseflow API with specified payload, endpoint, and optional headers.
    # returns the API's response
    def send_caseflow_request(payload, endpoint, headers = {})
      url = URI.join(caseflow_base_url, endpoint).to_s
      request = build_request(url, payload, headers)
      response = MetricsService.record("Caseflow Service: POST to #{endpoint}",
                                       service: :caseflow_service,
                                       name: "send_caseflow_request") do
        HTTPI.post(request)
      end
      logger.info(response.to_s)
      response
    end

    # Constructs an HTTPI request, setting timeouts, SSL configuration, headers and body
    def build_request(url, payload, headers)
      request = HTTPI::Request.new(url)
      request.open_timeout = 600 # seconds
      request.read_timeout = 600 # seconds
      request.auth.ssl.ssl_version  = :TLSv1_2
      request.auth.ssl.ca_cert_file = ENV["SSL_CERT_FILE"]
      request.headers = default_headers.merge(headers)
      request.body = payload.to_json
      request
    end

    # Default headers required for all requests to the Caseflow API, including authorization and content type.
    def default_headers
      {
        "AUTHORIZATION" => "Token token=#{caseflow_key}",
        "CSS-ID" => RequestStore[:current_user][:css_id],
        "STATION-ID" => RequestStore[:current_user][:station_id],
        "Content-type" => "application/json"
      }
    end

    def caseflow_base_url
      Rails.application.config.caseflow_url.to_s
    end

    def caseflow_key
      Rails.application.config.caseflow_key.to_s
    end

    # Builds headers to inlcude any PII that is scrubbed from the request body.
    def build_headers(drc_dto_builder)
      {
        "X-VA-Vet-SSN" => drc_dto_builder.vet_ssn,
        "X-VA-File-Number" => drc_dto_builder.vet_file_number,
        "X-VA-Vet-First-Name" => drc_dto_builder.vet_first_name,
        "X-VA-Vet-Last-Name" => drc_dto_builder.vet_last_name,
        "X-VA-Vet-Middle-Name" => drc_dto_builder.vet_middle_name,
        "X-VA-Claimant-SSN" => drc_dto_builder.claimant_ssn,
        "X-VA-Claimant-DOB" => drc_dto_builder.claimant_dob,
        "X-VA-Claimant-First-Name" => drc_dto_builder.claimant_first_name,
        "X-VA-Claimant-Last-Name" => drc_dto_builder.claimant_last_name,
        "X-VA-Claimant-Middle-Name" => drc_dto_builder.claimant_middle_name,
        "X-VA-Claimant-Email" => drc_dto_builder.claimant_email
      }
    end

    # Parses and checks the API response for errors, raising an exception for specific error conditions.
    def parse_response(response, claim_id)
      response_body = JSON.parse(response.body)
      check_for_error(response_body, response.code.to_i, claim_id)
      response
    end

    # Checks for common error responses and raises a custom exception of encountered.
    def check_for_error(response_body, code, claim_id)
      unless [200, 201].include?(code)
        msg = "Failed for claim_id: #{claim_id}, error: #{response_body}, HTTP code: #{code}"
        fail AppealsConsumer::Error::ClientRequestError, code: code, message: msg
      end
    end
  end
end
