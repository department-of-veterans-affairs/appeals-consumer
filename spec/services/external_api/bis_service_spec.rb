require 'bgs'
require_relative '../../../app/services/external_api/bis_service'

describe ExternalApi::BISService do
    let(:bis_veteran_service) { double("veteran") }
    let(:bis_people_service) { double("people") }
    let(:bis_org_service) { double("org") }
    let(:bis_client) { double("BGS::Services") }
    let(:bis) { ExternalApi::BISService.new(client: bis_client) }
    let(:veteran_record) { { name: "foo", ssn: "123" } }
    # person format BIS sends back
    let(:person_record) { { first_nm: "Bob", last_nm: "Vance", brthdy_dt: "Sun, 05 Sep 1943 00:00:00 -0500" }}
    # person format consumer app changes to
    let(:person_info) {{ 
      first_name: "Bob",
      last_name: "Vance",
      middle_name: nil,
      birth_date: "Sun, 05 Sep 1943 00:00:00 -0500",
      email_address: nil,
      file_number: nil,
      name_suffix: nil,
      ssn: nil 
    }}
    let(:bis_limited_poas) { { authzn_poa_access_ind: "Y", bnft_claim_id: "600130321", poa_cd: "OU3" } }
    let(:participant_id) { "123" }
    let(:file_number) { "55554444" }
    let(:cache_key) { "bis_veteran_info_#{file_number}" }
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      # veteran services
      allow(bis).to receive(:fetch_veteran_info).and_call_original
      allow(bis_client).to receive(:veteran).and_return(bis_veteran_service)
      allow(bis_veteran_service).to receive(:find_by_file_number) { veteran_record }
      # people services
      allow(bis).to receive(:fetch_person_info).and_call_original
      allow(bis_client).to receive(:people).and_return(bis_people_service)
      allow(bis_people_service).to receive(:find_person_by_ptcpnt_id) { person_record }
      #org services
      allow(bis).to receive(:fetch_limited_poas_by_claim_ids).and_call_original
      allow(bis_client).to receive(:org).and_return(bis_org_service)
      allow(bis_org_service).to receive(:find_limited_poas_by_bnft_claim_ids) { bis_limited_poas }

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
      end
    end

    describe "#fetch_person_info" do 
      it "returns person info" do
        pers_info = bis.fetch_person_info(participant_id)

        expect(bis_people_service).to have_received(:find_person_by_ptcpnt_id).once
        expect(pers_info).to eq(person_info)
      end
    end

    describe "#fetch_limited_poas_by_claim_ids" do 
      it "find_limited_poas_by_bnft_claim_ids is called" do
        bis_info = bis.fetch_limited_poas_by_claim_ids(nil)

        expect(bis_org_service).to have_received(:find_limited_poas_by_bnft_claim_ids).once
      end
    end
  end