# frozen_string_literal: true

class ExternalApi::CaseflowService
  BASE_ENDPOINT = "api/events/v1/"

  class << self
    def establish_decision_review_created_records_from_event!(drc_dto_builder)
      payload = drc_dto_builder.build_hash_response
      headers = build_headers(drc_dto_builder)
      endpoint = "#{BASE_ENDPOINT}decision_review_created"
      response = send_caseflow_request(payload, endpoint, headers)
      parse_response(response, payload["claim_id"])
    end

    def establish_decision_review_created_event_error!(event_id, claim_id, error_message)
      payload = { event_id: event_id, errored_claim_id: claim_id, error: error_message }
      endpoint = "#{BASE_ENDPOINT}decision_review_created_error"
      response = send_caseflow_request(payload, endpoint)
      parse_response(response, claim_id)
    end

    private

    def send_caseflow_request(payload, endpoint, headers = {})
      url = URI.join(caseflow_base_url, endpoint).to_s
      request = build_request(url, payload, headers)
      HTTPI.post(request)
    end

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

    def default_headers
      {
        "AUTHORIZATION" => "Token token=#{caseflow_key}",
        "CSS-ID" => ENV["CSS_ID"],
        "STATION-ID" => ENV["STATION_ID"],
        "Content-type" => "application/json"
      }
    end

    def caseflow_base_url
      Rails.application.config.caseflow_url.to_s
    end

    def caseflow_key
      Rails.application.config.caseflow_key.to_s
    end

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

    def parse_response(response, claim_id)
      response_body = JSON.parse(response.body)
      check_for_error(response_body, response.code.to_i, claim_id)
      response
    end

    def check_for_error(response_body, code, claim_id)
      if [409, 500].include?(code)
        msg = "Failed for claim_id: #{claim_id}, error: #{response_body}, HTTP code: #{code}"
        fail AppealsConsumer::Error::ClientRequestError, code: code, message: msg
      end
    end
  end
end
