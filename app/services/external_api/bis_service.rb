# frozen_string_literal: true

require "bgs"

# Thin interface to all things BIS formerly known as BGS
class ExternalApi::BISService
  include PowerOfAttorneyMapper

  attr_reader :client

  def initialize(client: init_client)
    @client = client

    # These instance variables are used for caching their
    # respective requests
    @veteran_info = {}
    @person_info = {}
    @poas = {}
  end

  def fetch_veteran_info(vbms_id)
    DBService.release_db_connections

    @veteran_info[vbms_id] ||=
      Rails.cache.fetch(fetch_veteran_info_cache_key(vbms_id), expires_in: 10.minutes) do
        MetricsService.record("BGS: fetch veteran info for vbms id: #{vbms_id}",
                              service: :bgs,
                              name: "veteran.find_by_file_number") do
          client.veteran.find_by_file_number(vbms_id)
        end
      end
  end

  def fetch_person_info(participant_id)
    DBService.release_db_connections

    bgs_info = MetricsService.record("BGS: fetch person info by participant id: #{participant_id}",
                                     service: :bgs,
                                     name: "people.find_person_by_ptcpnt_id") do
      client.people.find_person_by_ptcpnt_id(participant_id)
    end

    return {} unless bgs_info

    @person_info[participant_id] ||= {
      first_name: bgs_info[:first_nm],
      last_name: bgs_info[:last_nm],
      middle_name: bgs_info[:middle_nm],
      name_suffix: bgs_info[:suffix_nm],
      birth_date: bgs_info[:brthdy_dt],
      email_address: bgs_info[:email_addr],
      file_number: bgs_info[:file_nbr],
      ssn: bgs_info[:ssn_nbr]
    }
  end

  def fetch_limited_poas_by_claim_ids(claim_ids)
    DBService.release_db_connections

    bgs_limited_poas = MetricsService.record("BGS: fetch limited poas for claim ids: #{claim_ids}",
                                             service: :bgs,
                                             name: "org.find_limited_poas_by_bnft_claim_ids") do
      client.org.find_limited_poas_by_bnft_claim_ids(claim_ids)
    end

    get_limited_poas_hash_from_bgs(bgs_limited_poas)
  end

  private

  def current_user
    RequestStore[:current_user]
  end

  def fetch_veteran_info_cache_key(vbms_id)
    "bgs_veteran_info_#{vbms_id}"
  end

  def init_client
    forward_proxy_url = FeatureToggle.enabled?(:bgs_forward_proxy) ? ENV["RUBY_BGS_PROXY_BASE_URL"] : nil

    BGS::Services.new(
      env: Rails.application.config.bgs_environment,
      application: "CASEFLOW",
      client_ip: ENV.fetch("USER_IP_ADDRESS", Rails.application.secrets.user_ip_address),
      client_station_id: current_user.station_id,
      client_username: current_user.css_id,
      ssl_cert_key_file: ENV["BGS_KEY_LOCATION"],
      ssl_cert_file: ENV["BGS_CERT_LOCATION"],
      ssl_ca_cert: ENV["BGS_CA_CERT_LOCATION"],
      forward_proxy_url: forward_proxy_url,
      jumpbox_url: ENV["RUBY_BGS_JUMPBOX_URL"],
      log: true,
      logger: Rails.logger
    )
  end
end
