# frozen_string_literal: true

class Api::V1::JobsController < Api::V1::ApplicationController
  SCHEDULED_JOBS = {
    "heartbeat" => HeartbeatJob,
  }.freeze

  def create
    job = SCHEDULED_JOBS[params.require(:job_type)]
    return unrecognized_job unless job

    job = job.perform_later
    Rails.logger.info("Pushing: #{job} job_id: #{job.job_id} to queue: #{job.queue_name}")
    render json: { success: true, job_id: job.job_id }, status: :ok
  end

  def unrecognized_job
    render json: { error_code: "Unable to start unrecognized job" }, status: :unprocessable_entity
  end
end