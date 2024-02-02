# frozen_string_literal: true

class ExternalApi::CaseflowService
  def self.establish_decision_review_created_records_from_event!(drc_dto_builder)
    payload = drc_dto_builder.build_hash_response
    headers = build_headers(drc_dto_builder)
    endpoint = "api/events/v1/decision_review_created"
    response = send_caseflow_request(payload, headers, endpoint)
    response_body = JSON.parse(response.body)
    check_for_error(response_body, response.code)
    response.code
  end

  def self.establish_decision_review_created_event_error!(event_id, claim_id, error_message)
    payload = {}
    payload.event_id = event_id
    payload.claim_id = claim_id
    payload.error = error_message
    endpoint = "api/events/v1/decision_review_created_error"
    response = send_caseflow_request(payload, headers, endpoint)
    response_body = JSON.parse(response.body)
    check_for_error(response_body, response.code.to_i, payload.claim_id)
    response
  end

  def self.send_caseflow_request(payload, headers = {}, endpoint)
    url = URI::DEFAULT_PARSER.escape(caseflow_base_url + endpoint)
    request = HTTPI::Request.new(url)
    request.open_timeout = 600 # seconds
    request.read_timeout = 600 # seconds
    request.auth.ssl.ssl_version  = :TLSv1_2
    request.auth.ssl.ca_cert_file = ENV["SSL_CERT_FILE"]

    headers["AUTHORIZATION"] = "Token token=#{caseflow_key}"
    headers["CSS-ID"] = ENV["CSS-ID"]
    headers["STATION-ID"] = ENV["STATION-ID"]
    request.headers = headers

    request.body = payload

    HTTPI.post(request)
  end

  def self.casflow_base_url
    Rails.application.config.caseflow_url.to_s
  end

  def self.caseflow_key
    Rails.application.config.caseflow_key.to_s
  end

  def self.check_for_error(response_body, code, claim_id)
    if code == 409 || code == 500
      msg = "Failed for claim_id: #{claim_id}, error: #{response_body}, HTTP code: #{code}"
      fail AppealsConsumer::Error::ClientRequestError, code: code, message: msg
    end
  end

  def self.build_headers(drc_dto_builder)
    headers = {}
    headers["X-VA-Vet-SSN"] = drc_dto_builder.vet_ssn
    headers["X-VA-File-Number"] = drc_dto_builder.vet_file_number
    headers["X-VA-Vet-First-Name"] = drc_dto_builder.vet_fisrt_name
    headers["X-VA-Vet-Last-Name"] = drc_dto_builder.vet_last_name
    headers["X-VA-Vet-Middle-Name"] = drc_dto_builder.vet_middle_name
    headers["X-VA-Claiment-SSN"] = drc_dto_builder.claimant_ssn
    headers["X-VA-Claiment-DOB"] = drc_dto_builder.claiment_dob
    headers["X-VA-Claiment-First-Name"] = drc_dto_builder.claiment_first_name
    headers["X-VA-Claiment-Last-Name"] = drc_dto_builder.claiment_last_name
    headers["X-VA-Claiment-Middle-Name"] = drc_dto_builder.claiment_middle_name
    headers["X-VA-Claiment-Email"] = drc_dto_builder.claiment_email
    headers
  end
end
