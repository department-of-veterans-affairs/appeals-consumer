# frozen_string_literal: true

require "bgs"
require_relative "../../mappers/power_of_attorney_mapper"

module ExternalApi
  # BIS is formorlly known as BGS
  class BISService
    include PowerOfAttorneyMapper

    attr_reader :client

    def initialize(client: init_client)
      @client = client

      # These instance variables are used for caching their
      # respective requests
      @veteran_info = {}
      @person_info = {}
      @limited_poa = {}
    end

    def fetch_veteran_info(file_number)
      Rails.logger.info("BIS: Fetching veteran info for file number: #{file_number}")
      @veteran_info[file_number] ||=
        Rails.cache.fetch(fetch_veteran_info_cache_key(file_number), expires_in: 10.minutes) do
          client.veteran.find_by_file_number(file_number)
        end
    end

    def fetch_person_info(participant_id)
      Rails.logger.info("BIS: Fetching person info by participant id: #{participant_id}")
      bis_info = Rails.cache.fetch(fetch_person_info_cache_key(participant_id), expires_in: 10.minutes) do
        client.people.find_person_by_ptcpnt_id(participant_id)
      end

      return {} unless bis_info

      @person_info[participant_id] ||= {
        first_name: bis_info[:first_nm],
        last_name: bis_info[:last_nm],
        middle_name: bis_info[:middle_nm],
        name_suffix: bis_info[:suffix_nm],
        birth_date: bis_info[:brthdy_dt],
        email_address: bis_info[:email_addr],
        file_number: bis_info[:file_nbr],
        ssn: bis_info[:ssn_nbr]
      }
    end

    def fetch_limited_poas_by_claim_ids(claim_ids)
      Rails.logger.info("BIS: Fetching limited poas for claim ids: #{claim_ids}")
      @limited_poa[claim_ids] ||=
        Rails.cache.fetch(claim_ids, expires_in: 10.minutes) do
          bis_limited_poas = client.org.find_limited_poas_by_bnft_claim_ids(claim_ids)

          get_limited_poas_hash_from_bis(bis_limited_poas)
        end
    end

    def bust_fetch_veteran_info_cache(file_number)
      Rails.cache.delete(fetch_veteran_info_cache_key(file_number))
    end

    def bust_fetch_limited_poa_cache(claim_ids)
      Rails.cache.delete(claim_ids)
    end

    private

    def fetch_veteran_info_cache_key(file_number)
      "bis_veteran_info_#{file_number}"
    end

    def fetch_person_info_cache_key(participant_id)
      "bis_person_info_#{participant_id}"
    end

    # client_ip to be added but not needed for deployment and demo
    def init_client
      BGS::Services.new(
        env: Rails.application.config.bgs_environment,
        application: "APPEALSCONSUMER",
        client_ip: ENV["USER_IP_ADDRESS"],
        client_station_id: Rails.application.config.station_id,
        client_username: Rails.application.config.css_id,
        ssl_cert_key_file: ENV["BGS_KEY_LOCATION"],
        ssl_cert_file: ENV["BGS_CERT_LOCATION"],
        ssl_ca_cert: ENV["BGS_CA_CERT_LOCATION"],
        forward_proxy_url: ENV["RUBY_BGS_PROXY_BASE_URL"],
        jumpbox_url: ENV["RUBY_BGS_JUMPBOX_URL"],
        log: true,
        logger: Rails.logger
      )
    end
  end
end
