# frozen_string_literal: true

class Api::V1::ApplicationController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  private

  def authenticate_with_token
    @authenticate_with_token ||= authenticate_with_http_token do |token, _options|
      token == Rails.application.config.api_key
    end
  end

  def unauthorized
    render json: { status: "unauthorized" }, status: :unauthorized
  end

  def authenticate
    if !authenticate_with_token
      unauthorized
    end
  end
end
