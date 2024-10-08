# frozen_string_literal: true

require "bgs"
require "spec_helper"
require_relative "../../../app/services/external_api/bis_service"

describe ExternalApi::BISService do
  let(:bis_veteran_service) { double("veteran") }
  let(:bis_people_service) { double("people") }
  let(:bis_org_service) { double("org") }
  let(:bis_rating_profile_service) { double("rating_profile") }
  let(:bis_client) { double("BGS::Services") }
  let(:bis) { ExternalApi::BISService.new(client: bis_client) }
  let(:veteran_record) { { name: "foo", ssn: "123" } }
  # person format BIS sends back
  let(:person_record) { { first_nm: "Bob", last_nm: "Vance", brthdy_dt: "Sun, 05 Sep 1943 00:00:00 -0500" } }
  # person format consumer app changes to
  let(:person_info) do
    {
      first_name: "Bob",
      last_name: "Vance",
      middle_name: nil,
      birth_date: "Sun, 05 Sep 1943 00:00:00 -0500",
      email_address: nil,
      file_number: nil,
      name_suffix: nil,
      ssn: nil
    }
  end
  let(:bis_limited_poas) { { authzn_poa_access_ind: "Y", bnft_claim_id: "600130321", poa_cd: "OU3" } }
  let(:participant_id) { "123" }
  let(:file_number) { "55554444" }
  let(:cache_key) { "bis_veteran_info_#{file_number}" }
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }
  let(:rating_profiles) do
    {
      rba_issue_list: {
        rba_issue: {
          rba_issue_id: "123456",
          prfil_date: Date.new(1980, 1, 1)
        }
      },
      rba_claim_list: {
        rba_claim: {
          bnft_clm_tc: "030HLRR",
          clm_id: "1002003",
          prfl_date: Date.new(1980, 1, 1)
        }
      }
    }
  end

  before do
    # veteran services
    allow(bis).to receive(:fetch_veteran_info).and_call_original
    allow(bis_client).to receive(:veteran).and_return(bis_veteran_service)
    allow(bis_veteran_service).to receive(:find_by_file_number) { veteran_record }
    # people services
    allow(bis).to receive(:fetch_person_info).and_call_original
    allow(bis_client).to receive(:people).and_return(bis_people_service)
    allow(bis_people_service).to receive(:find_person_by_ptcpnt_id) { person_record }
    # org services
    allow(bis).to receive(:fetch_limited_poas_by_claim_ids).and_call_original
    allow(bis_client).to receive(:org).and_return(bis_org_service)
    allow(bis_org_service).to receive(:find_limited_poas_by_bnft_claim_ids) { bis_limited_poas }
    # rating profile services
    allow(bis).to receive(:fetch_rating_profiles_in_range).and_call_original
    allow(bis_client).to receive(:rating_profile).and_return(bis_rating_profile_service)
    allow(bis_rating_profile_service).to receive(:find_in_date_range) { rating_profiles }

    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  after do
    bis.bust_fetch_veteran_info_cache(file_number)
  end

  describe "#fetch_veteran_info" do
    context "when called without previous .can_access?" do
      it "reads from BIS" do
        vet_record = bis.fetch_veteran_info(file_number)

        expect(bis_veteran_service).to have_received(:find_by_file_number).once
        expect(vet_record).to eq(veteran_record)
        expect(Rails.cache.exist?(cache_key)).to be_truthy
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:emit_gauge)
        bis.fetch_veteran_info(file_number)
      end
    end
  end

  describe "#fetch_person_info" do
    it "returns person info" do
      # addding a comment to run tests again again
      pers_info = bis.fetch_person_info(participant_id)

      expect(bis_people_service).to have_received(:find_person_by_ptcpnt_id).once
      expect(pers_info).to eq(person_info)
    end

    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:emit_gauge)
      bis.fetch_person_info(participant_id)
    end
  end

  describe "#fetch_limited_poas_by_claim_ids" do
    let!(:claim_ids) { %w[600130321 1 2] }

    after do
      bis.bust_fetch_limited_poa_cache(claim_ids)
    end

    it "find_limited_poas_by_bnft_claim_ids is called" do
      bis.fetch_limited_poas_by_claim_ids(claim_ids)
      expect(bis_org_service).to have_received(:find_limited_poas_by_bnft_claim_ids).once
    end

    it "should set cache key,value if not exists" do
      expect(Rails.cache.exist?(claim_ids)).to eq false
      bis_info = bis.fetch_limited_poas_by_claim_ids(claim_ids)
      expect(Rails.cache.exist?(claim_ids)).to eq true
      expect(Rails.cache.read(claim_ids)).to eq bis_info
    end

    it "should retrieve cache key,value if exists" do
      expect(Rails.cache.exist?(claim_ids)).to eq false
      bis_info = bis.fetch_limited_poas_by_claim_ids(claim_ids)
      Rails.cache.write(claim_ids, bis_info)
      expect(Rails.cache.read(claim_ids)).to eq bis_info
    end

    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:emit_gauge)
      bis.fetch_limited_poas_by_claim_ids(claim_ids)
    end
  end

  describe "#fetch_rating_profiles_in_range(participant_id:, start_date:, end_date:)" do
    let!(:participant_id) { "123456789" }
    let!(:start_date) { "2017-02-07T07:21:24+00:00" }
    let!(:end_date) { "2017-02-07T07:21:24+00:00" }
    let!(:formatted_start_date) { start_date.to_date }
    let!(:formatted_end_date) { end_date.to_date }
    let!(:cache_key) { "bis_rating_profiles_#{participant_id}_#{formatted_start_date}_#{formatted_end_date}" }
    let(:msg) do
      "Fetching rating profiles for participant_id #{participant_id}"\
        " within the date range #{formatted_start_date} - #{formatted_end_date}"
    end

    subject do
      bis.fetch_rating_profiles_in_range(participant_id: participant_id, start_date: start_date, end_date: end_date)
    end

    before do
      allow(Rails.logger).to receive(:info)
    end

    after do
      bis.bust_fetch_rating_profiles_in_range_cache(participant_id, formatted_start_date, formatted_end_date)
    end

    it "fetch_rating_profiles_in_range is called" do
      subject
      expect(bis_rating_profile_service).to have_received(:find_in_date_range).once
      expect(Rails.logger).to have_received(:info)
        .with(/#{msg}/)
    end

    it "should set cache key,value if not exists" do
      expect(Rails.cache.exist?(cache_key)).to eq false
      subject
      expect(Rails.cache.exist?(cache_key)).to eq true
      expect(Rails.cache.read(cache_key)).to eq subject
    end

    it "should retrieve cache key,value if exists" do
      expect(Rails.cache.exist?(cache_key)).to eq false
      subject
      Rails.cache.write(cache_key, subject)
      expect(Rails.cache.read(cache_key)).to eq subject
    end

    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:emit_gauge)
      subject
    end
  end
end
