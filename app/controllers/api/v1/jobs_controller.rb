# frozen_string_literal: true

class Api::V1::JobsController < Api::V1::ApplicationController
  def create
    puts "Job received"
    render json: { success: true }, status: :ok
  end
end
