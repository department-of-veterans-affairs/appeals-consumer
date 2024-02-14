# frozen_string_literal: true

class ApplicationController < ActionController::API
  class << self
    def dependencies_faked?
      Rails.env.test? ||
        Rails.env.demo? ||
        Rails.env.ssh_forwarding? ||
        Rails.env.development?
    end
  end
end
