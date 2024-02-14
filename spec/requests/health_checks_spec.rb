# frozen_string_literal: true

describe "Health Check", type: :request do
  describe "#show" do
    before do
      Rails.application.config.build_version = { commit: "The deployed git hash"}
    end

    it "returns healthy status and the git hash used for deployment" do
      get "/health-check"

      expect(response.status).to eq(200)

      json = JSON.parse(response.body)
      expect(json["healthy"]).to eq(true)
      expect(json["commit"]).to eq("The deployed git hash")
    end
  end
end