# frozen_string_literal: true

module Lkr
  module Dashboard
    def query_dashboard(dashboard_id)
      data = nil
      begin
        data = @sdk.dashboard(dashboard_id)
      rescue LookerSDK::Error => e
          say_error "Error querying dashboard(#{dashboard_id})"
          say_error e.message
          raise
      end
      data
    end
  end
end