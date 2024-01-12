class SentryController < ApplicationController
  def simulate_error
    raise StandardError, "This is a simulated error!"
  end
end
