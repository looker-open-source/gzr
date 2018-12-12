# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# frozen_string_literal: true

module Gzr
  module Plan
    def query_all_scheduled_plans(user_id,fields=nil)
      req = {}
      req[:all_users] = true if user_id == "all"
      req[:user_id] = user_id if user_id && !(user_id == "all")
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
    
    def query_scheduled_plans_for_look(look_id,user_id,fields=nil)
      req = {}
      req[:all_users] = true if user_id == "all"
      req[:user_id] = user_id if user_id && !(user_id == "all")
      req[:fields] = fields if fields
      data = nil
      begin
        data = @sdk.scheduled_plans_for_look(look_id,req)
      rescue LookerSDK::ClientError => e
        say_error "Unable to get scheduled_plans_for_look(#{look_id},#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end
    
    def query_scheduled_plans_for_dashboard(dashboard_id,user_id,fields=nil)
      req = {}
      req[:all_users] = true if user_id == "all"
      req[:user_id] = user_id if user_id && !(user_id == "all")
      req[:fields] = fields if fields
      data = nil
      begin
        data = @sdk.scheduled_plans_for_dashboard(dashboard_id,req)
      rescue LookerSDK::ClientError => e
        say_error "Unable to get scheduled_plans_for_dashboard(#{dashboard_id},#{JSON.pretty_generate(req)})"
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
    
    def delete_scheduled_plan(plan_id)
      begin
        data = @sdk.delete_scheduled_plan(plan_id)
      rescue LookerSDK::ClientError => e
        say_error "Unable to delete scheduled_plan(#{plan_id})"
        say_error e.message
        raise
      end
      data
    end

    def create_scheduled_plan(plan)
      begin
        data = @sdk.create_scheduled_plan(plan)
      rescue LookerSDK::Error => e
        say_error "Error creating scheduled_plan(#{JSON.pretty_generate(plan)})"
        say_error e.message
        raise
      end
      data
    end

    def update_scheduled_plan(plan_id,plan)
      begin
        data = @sdk.update_scheduled_plan(plan_id,plan)
      rescue LookerSDK::Error => e
        say_error "Error updating scheduled_plan(#{plan_id},#{JSON.pretty_generate(plan)})"
        say_error e.message
        raise
      end
      data
    end

    def run_scheduled_plan(plan)
      begin
        data = @sdk.scheduled_plan_run_once(plan)
      rescue LookerSDK::Error => e
        say_error "Error executing scheduled_plan_run_once(#{JSON.pretty_generate(plan)})"
        say_error e.message
        raise
      end
      data
    end
    
    def upsert_plans_for_look(look_id,user_id,source_plans)
      existing_plans = query_scheduled_plans_for_look(look_id,"all")
      upsert_plans_for_obj(user_id,source_plans,existing_plans) { |p| p[:look_id] = look_id }
    end
    
    def upsert_plans_for_dashboard(dashboard_id,user_id,source_plans)
      existing_plans = query_scheduled_plans_for_dashboard(dashboard_id,"all")
      upsert_plans_for_obj(user_id,source_plans,existing_plans) { |p| p[:dashboard_id] = dashboard_id }
    end
    
    def upsert_plan_for_look(look_id,user_id,source_plan)
      existing_plans = query_scheduled_plans_for_look(look_id,"all")
      upsert_plan_for_obj(user_id,source_plan,existing_plans) { |p| p[:look_id] = look_id }
    end
    
    def upsert_plan_for_dashboard(dashboard_id,user_id,source_plan)
      existing_plans = query_scheduled_plans_for_dashboard(dashboard_id,"all")
      upsert_plan_for_obj(user_id,source_plan,existing_plans) { |p| p[:dashboard_id] = dashboard_id }
    end
    
    def upsert_plans_for_obj(user_id,source_plans,existing_plans, &block)
      plans = nil
      source_plans.collect do |source_plan|
        plans = upsert_plan_for_obj(user_id, source_plan, existing_plans, &block)
      end
      return nil unless plans.length > 0
      plans.first
    end

    def upsert_plan_for_obj(user_id, source_plan, existing_plans)
      matches = existing_plans.select { |p| p.name == source_plan[:name] && user_id == p.user_id }
      if matches.length > 0 then
        say_ok "Modifying existing plan #{matches.first.id} #{matches.first.name}"
        plan = keys_to_keep('update_scheduled_plan').collect do |e|
          [e,nil]
        end.to_h

        plan.merge!( source_plan.select do |k,v|
          (keys_to_keep('update_scheduled_plan') - [:plan_id,:look_id,:dashboard_id,:user_id,:dashboard_filters,:lookml_dashboard_id,:scheduled_plan_destination]).include? k
        end)
        plan[:scheduled_plan_destination] = source_plan[:scheduled_plan_destination].collect do |p|
          p.reject do |k,v|
            [:id,:scheduled_plan_id,:looker_recipient,:can].include? k
          end
        end
        plan[:user_id] = user_id
        plan[:enabled] = true if @options[:enabled]
        plan[:enabled] = false if @options[:disabled]

        plan[:enabled] = false if plan[:enabled].nil?
        plan[:require_results] = false if plan[:require_results].nil?
        plan[:require_no_results] = false if plan[:require_no_results].nil?
        plan[:require_change] = false if plan[:require_change].nil?
        plan[:send_all_results] = false if plan[:send_all_results].nil?
        plan[:run_once] = false if plan[:run_once].nil?
        plan[:include_links] = false if plan[:include_links].nil?
        yield plan
        update_scheduled_plan(matches.first.id,plan)
      else
        plan = source_plan.select do |k,v|
          (keys_to_keep('create_scheduled_plan') - [:plan_id,:dashboard_id,:user_id,:dashboard_filters,:lookml_dashboard_id,:scheduled_plan_destination]).include? k
        end
        plan[:scheduled_plan_destination] = source_plan[:scheduled_plan_destination].collect do |p|
          p.reject do |k,v|
            [:id,:scheduled_plan_id,:looker_recipient,:can].include? k
          end
        end

        yield plan
        plan[:enabled] = true if @options[:enabled]
        plan[:enabled] = false if @options[:disabled]

        plan[:enabled] = false if plan[:enabled].nil?
        plan[:require_results] = false if plan[:require_results].nil?
        plan[:require_no_results] = false if plan[:require_no_results].nil?
        plan[:require_change] = false if plan[:require_change].nil?
        plan[:send_all_results] = false if plan[:send_all_results].nil?
        plan[:run_once] = false if plan[:run_once].nil?
        plan[:include_links] = false if plan[:include_links].nil?
        create_scheduled_plan(plan)
      end
    end
  end
end
