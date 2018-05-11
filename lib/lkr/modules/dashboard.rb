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

    def delete_dashboard(dash)
      data = nil
      begin
        data = @sdk.delete_dashboard(dash)
      rescue LookerSDK::Error => e
          say_error "Error deleting dashboard(#{dash})"
          say_error e.message
          raise
      end
      data
    end

    def search_dashboards(title, space_id=nil)
      data = nil
      begin
        req = { :title => title }
        req[:space_id] = space_id if space_id 
        data = @sdk.search_dashboards(req)
      rescue LookerSDK::Error => e
        say_error "Error search_dashboards(#{JSON.pretty_generate(req)})"
        say_error e.message
        raise
      end
      data
    end

    def create_dashboard(dash)
      begin
        data = @sdk.create_dashboard(dash)
      rescue LookerSDK::Error => e
          say_error "Error creating dashboard"
          say_error e.message
          raise
      end
      data
    end

    def create_dashboard_element(dash_elem)
      begin
        data = @sdk.create_dashboard_element(dash_elem)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_element(#{JSON.pretty_generate(dash_elem)})"
        say_error e.message
        raise
      end
      data
    end

    def create_dashboard_layout(dash_layout)
      begin
        data = @sdk.create_dashboard_layout(dash_layout)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_layout(#{JSON.pretty_generate(dash_layout)})"
        say_error e.message
        raise
      end
      data
    end

    def update_dashboard_layout(id,dash_layout)
      begin
        data = @sdk.update_dashboard_layout(id,dash_layout)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_layout(#{id},#{JSON.pretty_generate(dash_layout)})"
        say_error e.message
        raise
      end
      data
    end

    def delete_dashboard_layout(id)
      begin
        data = @sdk.delete_dashboard_layout(id)
      rescue LookerSDK::Error => e
        say_error "Error deleting dashboard_layout(#{id})"
        say_error e.message
        raise
      end
      data
    end

    def update_dashboard_layout_component(id,component)
      begin
        data = @sdk.update_dashboard_layout_component(id,component)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_layout_component(#{id},#{JSON.pretty_generate(component)})"
        say_error e.message
        raise
      end
      data
    end

    def create_dashboard_filter(dash_filter)
      begin
        data = @sdk.create_dashboard_filter(dash_filter)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_filter(#{JSON.pretty_generate(dash_filter)})"
        say_error e.message
        raise
      end
      data
    end

  end
end