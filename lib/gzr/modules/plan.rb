# frozen_string_literal: true

module Gzr
  module Plan
    def query_all_scheduled_plans(user_id,fields=nil)
      req = {}
      req[:all_users] = true if user_id == "all"
      req[:fields] = fields if fields
      data = nil
      id = nil
      id = user_id unless user_id == "all"
      begin
        data = @sdk.all_scheduled_plans(req)
      rescue LookerSDK::ClientError => e
        say_error "Unable to get all_scheduled_plans(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
    def query_scheduled_plan(plan_id,fields=nil)
      req = {}
      req[:fields] = fields if fields
      begin
        data = @sdk.scheduled_plan(plan_id,req)
      rescue LookerSDK::ClientError => e
        say_error "Unable to get scheduled_plan(#{plan_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
  end
end
