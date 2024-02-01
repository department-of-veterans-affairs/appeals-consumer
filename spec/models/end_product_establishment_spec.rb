# frozen_string_literal: true

describe EndProductEstablishment do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  let(:end_product_establishment) { build(:end_product_establishment) }

  it "allows reader and writer access for attributes" do
    expect(end_product_establishment.benefit_type_code).to eq("0")
    expect(end_product_establishment.claim_date).to eq(Date.new(2022, 1, 1))
    expect(end_product_establishment.code).to eq("030HLRR")
    expect(end_product_establishment.modifier).to eq("030")
    expect(end_product_establishment.payee_code).to eq("00")
    expect(end_product_establishment.limited_poa_access).to eq(nil)
    expect(end_product_establishment.limited_poa_code).to eq(nil)
    expect(end_product_establishment.committed_at).to eq(Time.now.utc)
    expect(end_product_establishment.established_at).to eq(Time.now.utc)
    expect(end_product_establishment.last_synced_at).to eq(Time.now.utc)
    expect(end_product_establishment.synced_status).to eq("RFD")
    expect(end_product_establishment.development_item_reference_id).to eq(nil)
    expect(end_product_establishment.reference_id).to eq("147852369")
  end
end
