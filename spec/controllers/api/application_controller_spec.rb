# frozen_string_literal: true

RSpec.describe Api::ApplicationController, type: :controller do
  let(:api_key) { "token" }

  describe "before_action :authenticate" do
    controller(Api::ApplicationController) do
      before_action :authenticate
      def index
        render json: { message: "success" }, status: :ok
      end
    end

    context "with valid API key" do
      it "should allow access to the API" do
        request.headers["Authorization"] = "Token #{api_key}"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid API key" do
      it "should deny access to the API" do
        request.headers["Authorization"] = "Token INVALID_API_KEY"
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without API key" do
      it "should deny access to the API" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
