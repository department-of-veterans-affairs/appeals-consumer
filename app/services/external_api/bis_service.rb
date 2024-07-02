# frozen_string_literal: true

require "bgs"
require_relative "../../mappers/power_of_attorney_mapper"
require_dependency "logger_mixin"

module ExternalApi
  # BIS is formorlly known as BGS
  class BISService
    include LoggerMixin
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
      logger.info("Fetching veteran info for file number: #{file_number}")
      @veteran_info[file_number] ||=
        Rails.cache.fetch(fetch_veteran_info_cache_key(file_number), expires_in: 10.minutes) do
          MetricsService.record("BIS: fetch veteran info for file number: #{file_number}",
                                service: :bis,
                                name: "veteran.find_by_file_number") do
            case Event.last.id
            when 169
              fail StandardError, "Veteran Test Error"
            else
              client.veteran.find_by_file_number(file_number)
            end
          end
        end
    end

    # rubocop:disable Metrics/MethodLength

    def fetch_person_info(participant_id)
      logger.info("Fetching person info by participant id: #{participant_id}")
      Rails.cache.fetch(fetch_person_info_cache_key(participant_id), expires_in: 10.minutes) do
        MetricsService.record("BIS: fetch person info for participant id: #{participant_id}",
                              service: :bis,
                              name: "people.find_person_by_ptcpnt_id") do
          case Event.last.id
          when 170
            fail StandardError, "Person Test Error"
          when 176
            {}
          when 177
            {
              name_suffix: nil,
              ssn: nil,
              date_of_birth: nil,
              first_name: nil,
              middle_name: nil,
              last_name: nil,
              email: nil
            }
          else
            bis_info = client.people.find_person_by_ptcpnt_id(participant_id)
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
        end
      end
    end

    def fetch_limited_poas_by_claim_ids(claim_ids)
      logger.info("Fetching limited poas for claim ids: #{claim_ids}")
      @limited_poa[claim_ids] ||=
        Rails.cache.fetch(claim_ids, expires_in: 10.minutes) do
          MetricsService.record("BIS: fetch limited poas by claim ids: #{claim_ids}",
                                service: :bis,
                                name: "org.find_limited_poas_by_bnft_claim_ids") do
            case Event.last.id
            when 171
              fail StandardError, "Limited POA Test Error"
            when 173
              {
                claim_ids =>
                {
                  limited_poa_access: "Y",
                  limited_poa_code: "AccessCode"
                }
              }
            when 174
              {
                claim_ids =>
                {
                  limited_poa_access: "N",
                  limited_poa_code: "AccessDeniedCode"
                }
              }
            else
              bis_limited_poas = client.org.find_limited_poas_by_bnft_claim_ids(claim_ids)
              get_limited_poas_hash_from_bis(bis_limited_poas)
            end
          end
        end
    end

    def fetch_rating_profiles_in_range(participant_id:, start_date:, end_date:)
      start_date, end_date = formatted_start_and_end_dates(start_date, end_date)
      logger.info(
        "Fetching rating profiles for participant_id #{participant_id}"\
        " within the date range #{start_date} - #{end_date}"
      )

      Rails.cache.fetch(fetch_rating_profiles_in_range_cache_key(participant_id, start_date, end_date),
                        expires_in: 10.minutes) do
        MetricsService.record("BIS: fetch rating profiles in range: \
            participant_id = #{participant_id}, \
            start_date = #{start_date} \
            end_date = #{end_date}",
                              service: :bis,
                              name: "rating_profile.find_in_date_range") do
          if Event.last.id == 172
            fail StandardError, "Rating Profile Test Error"
          elsif Event.last.id == 175
            {
              rba_claim_list: {
                rba_claim: [
                  {
                    bnft_clm_tc: "682HLRRRAMP",
                    clm_id: "1002003",
                    prfl_date: start_date
                  }
                ]
              },
              response: {
                response_text: "Success"
              }
            }
          else
            client.rating_profile.find_in_date_range(
              participant_id: participant_id,
              start_date: start_date,
              end_date: end_date
            )
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength

    def bust_fetch_veteran_info_cache(file_number)
      Rails.cache.delete(fetch_veteran_info_cache_key(file_number))
    end

    def bust_fetch_limited_poa_cache(claim_ids)
      Rails.cache.delete(claim_ids)
    end

    def bust_fetch_rating_profiles_in_range_cache(participant_id, start_date, end_date)
      Rails.cache.delete(fetch_rating_profiles_in_range_cache_key(participant_id, start_date, end_date))
    end

    private

    def fetch_veteran_info_cache_key(file_number)
      "bis_veteran_info_#{file_number}"
    end

    def fetch_person_info_cache_key(participant_id)
      "bis_person_info_#{participant_id}"
    end

    def fetch_rating_profiles_in_range_cache_key(participant_id, start_date, end_date)
      "bis_rating_profiles_#{participant_id}_#{start_date}_#{end_date}"
    end

    def formatted_start_and_end_dates(start_date, end_date)
      # start_date and end_date should be Dates with different values
      return_start_date = start_date.to_date
      return_end_date = end_date.to_date
      [return_start_date, return_end_date]
    end

    def current_user
      RequestStore[:current_user]
    end

    # client_ip to be added but not needed for deployment and demo
    def init_client
      BGS::Services.new(
        env: Rails.application.config.bgs_environment,
        application: "CASEFLOW",
        client_ip: ENV["USER_IP_ADDRESS"],
        client_station_id: current_user[:station_id],
        client_username: current_user[:css_id],
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
