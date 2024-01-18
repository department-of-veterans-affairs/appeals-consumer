# frozen_string_literal: true

describe PowerOfAttorneyMapper do
  let(:poa_mapper) { Class.new { include PowerOfAttorneyMapper } }

  context "#get_limited_poas_hash_from_bis" do
    context "when the response is nil" do
      let(:bis_response) { nil }

      it "returns nil" do
        limited_poas = poa_mapper.get_limited_poas_hash_from_bis(bis_response)
        expect(limited_poas).to be_nil
      end
    end

    context "when a single limited poa is returned" do
      let(:bis_response) { { authzn_poa_access_ind: "Y", bnft_claim_id: "600130321", poa_cd: "OU3" } }

      it "returns a hash keyed by claim id" do
        limited_poas = poa_mapper.get_limited_poas_hash_from_bis(bis_response)
        expect(limited_poas).to eq(
          "600130321" => { limited_poa_code: "OU3", limited_poa_access: "Y" }
        )
      end
    end

    context "when an array of multiple limited poas are returned" do
      let(:bis_response) do
        [
          { authzn_poa_access_ind: "Y", bnft_claim_id: "600130321", poa_cd: "OU3" },
          { authzn_poa_access_ind: "Y", bnft_claim_id: "600137450", poa_cd: "084" },
          { authzn_change_clmant_addrs_ind: "N", authzn_poa_access_ind: "N", bnft_claim_id: "600149269", poa_cd: "007" }
        ]
      end

      it "returns a hash keyed by claim id" do
        limited_poas = poa_mapper.get_limited_poas_hash_from_bis(bis_response)

        expect(limited_poas).to eq(
          "600130321" => { limited_poa_code: "OU3", limited_poa_access: "Y" },
          "600137450" => { limited_poa_code: "084", limited_poa_access: "Y" },
          "600149269" => { limited_poa_code: "007", limited_poa_access: "N" }
        )
      end
    end
  end
end 