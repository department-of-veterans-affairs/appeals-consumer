# frozen_string_literal: true

describe EndProductEstablishment do
  let(:end_product_establishment) { build(:end_product_establishment) }

  it "allows reader and writer access for attributes" do
    expect(end_product_establishment.claim_date).to eq(Date.new(2022, 1, 1))
    expect(end_product_establishment.code).to eq("030HLRR")
    expect(end_product_establishment.modifier).to eq("030")
    expect(end_product_establishment.reference_id).to eq("147852369")
  end
end
