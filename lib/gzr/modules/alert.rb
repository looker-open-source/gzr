# The MIT License (MIT)

# Copyright (c) 2023 Mike DeAngelo Google, Inc.

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
  module Alert
    def get_alert(alert_id)
      data = nil
      begin
        data = @sdk.get_alert(alert_id).to_attrs
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying get_alert(#{alert_id})"
        say_error e
        raise
      end
      if data and data[:owner_id]
        owner = get_user_by_id(data[:owner_id])
        data[:owner] = owner.select do |k,v|
          [:email,:last_name,:first_name].include?(k) && !(v.nil? || v.empty?)
        end if owner
      end
      data
    end

    def search_alerts(group_by: nil, fields: nil, disabled: nil, frequency: nil, condition_met: nil, last_run_start: nil, last_run_end: nil, all_owners: nil)
      data = []
      begin
        req = {}
        req[:group_by] = group_by unless group_by.nil?
        req[:fields] = fields unless fields.nil?
        req[:disabled] = disabled unless disabled.nil?
        req[:frequency] = frequency unless frequency.nil?
        req[:condition_met] = condition_met unless condition_met.nil?
        req[:last_run_start] = last_run_start unless last_run_start.nil?
        req[:last_run_end] = last_run_end unless last_run_end.nil?
        req[:all_owners] = all_owners unless all_owners.nil?
        req[:limit] = 64
        loop do
          page = @sdk.search_alerts(req).collect { |a| a.to_attrs }
          data+=page
          break unless page.length == req[:limit]
          req[:offset] = (req[:offset] || 0) + req[:limit]
        end
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying search_alerts(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def follow_alert(alert_id)
      begin
        @sdk.follow_alert(alert_id)
      rescue LookerSDK::NotFound => e
        say_error "Alert #{alert_id} not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error following alert(#{alert_id})"
        say_error e
        raise
      end
    end

    def unfollow_alert(alert_id)
      begin
        @sdk.unfollow_alert(alert_id)
      rescue LookerSDK::NotFound => e
        say_error "Alert #{alert_id} not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error unfollowing alert(#{alert_id})"
        say_error e
        raise
      end
    end

    def update_alert_field(alert_id, owner_id: nil, is_disabled: nil, disabled_reason: nil, is_public: nil, threshold: nil)
      req = {}
      req[:owner_id] = owner_id unless owner_id.nil?
      req[:is_disabled] = is_disabled unless is_disabled.nil?
      req[:disabled_reason] = disabled_reason unless disabled_reason.nil?
      req[:is_public] = is_public unless is_public.nil?
      req[:threshold] = threshold unless threshold.nil?
      begin
        @sdk.update_alert_field(alert_id, req).to_attrs
      rescue LookerSDK::NotFound => e
        say_error "Alert #{alert_id} not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error calling update_alert_field(#{alert_id},#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
    end

    def delete_alert(alert_id)
      begin
        @sdk.delete_alert(alert_id)
      rescue LookerSDK::NotFound => e
        say_error "Alert #{alert_id} not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error calling delete_alert(#{alert_id})"
        say_error e
        raise
      end
    end

    def alert_notifications()
      data = []
      req = {}
      begin
        req[:limit] = 64
        loop do
          page = @sdk.alert_notifications(req).collect { |a| a.to_attrs }
          data+=page
          break unless page.length == req[:limit]
          req[:offset] = (req[:offset] || 0) + req[:limit]
        end
      rescue LookerSDK::NotFound => e
        # do nothing
      rescue LookerSDK::Error => e
        say_error "Error querying alert_notifications()"
        say_error e
        raise
      end
      data
    end

    def read_alert_notification(notification_id)
      begin
        @sdk.read_alert_notification(notification_id).to_attrs
      rescue LookerSDK::NotFound => e
        say_error "Alert notification #{notification_id} not found"
        say_error e
        raise
      rescue LookerSDK::Error => e
        say_error "Error calling read_alert_notification(#{notification_id})"
        say_error e
        raise
      end
    end

    def create_alert(req)
      begin
        @sdk.create_alert(req).to_attrs
      rescue LookerSDK::Error => e
        say_error "Error calling create_alert(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
    end
  end
end
