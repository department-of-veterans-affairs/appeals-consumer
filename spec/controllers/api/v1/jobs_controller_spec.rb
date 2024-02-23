# frozen_string_literal: true

RSpec.describe Api::V1::JobsController, :postgres, type: :controller do
  let(:api_key) { "token" }

  before(:each) do
    request.headers["Authorization"] = "Token #{api_key}"
  end

  describe "POST job create" do
    it "should not be successful due to unauthorized request" do
      # set up the wrong token
      request.headers["Authorization"] = "BADTOKEN"
      post :create, params: { "job_type": "UndefinedJob" }
      expect(response.status).to eq 401
    end

    it "should not be successful due to unrecognized job" do
      post :create, params: { "job_type": "UndefinedJob" }
      expect(response.status).to eq 422
    end

    it "should successfully start StatsCollectorJob asynchronously" do
      allow(HeartbeatJob).to receive(:perform_later).and_return(HeartbeatJob.new)
      post :create, params: { "job_type": "heartbeat" }
      expect(response.status).to eq 200
      expect(response_body["job_id"]).not_to be_empty
    end
  end

  def response_body
    JSON.parse(response.body)
  end
end
