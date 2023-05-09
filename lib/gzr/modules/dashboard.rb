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
require_relative 'alert'

module Gzr
  module Dashboard
    include Gzr::Alert

    def query_dashboard(dashboard_id)
      data = nil
      begin
        data = @sdk.dashboard(dashboard_id)
        data&.dashboard_filters&.sort! { |a,b| a.row <=> b.row }
        data&.dashboard_layouts&.sort_by! { |v| (v.active ? 0 : 1) }
      rescue LookerSDK::Error => e
        say_error "Error querying dashboard(#{dashboard_id})"
        say_error e
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
        say_error e
        raise
      end
      data
    end

    def search_dashboards_by_slug(slug, folder_id=nil)
      data = []
      begin
        req = { :slug => slug }
        req[:folder_id] = folder_id if folder_id
        data = @sdk.search_dashboards(req)
        req[:deleted] = true
        data = @sdk.search_dashboards(req) if data.empty?
      rescue LookerSDK::Error => e
        say_error "Error search_dashboards_by_slug(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def search_dashboards_by_title(title, folder_id=nil)
      data = []
      begin
        req = { :title => title }
        req[:folder_id] = folder_id if folder_id
        data = @sdk.search_dashboards(req)
        req[:deleted] = true
        data = @sdk.search_dashboards(req) if data.empty?
      rescue LookerSDK::Error => e
        say_error "Error search_dashboards_by_title(#{JSON.pretty_generate(req)})"
        say_error e
        raise
      end
      data
    end

    def create_dashboard(dash)
      begin
        data = @sdk.create_dashboard(dash)
        say_error data.inspect if data.respond_to?(:message)
        data&.dashboard_filters&.sort! { |a,b| a.row <=> b.row }
        data&.dashboard_layouts&.sort_by! { |v| (v.active ? 0 : 1) }
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard(#{JSON.pretty_generate(dash)})"
        say_error e
        raise
      end
      data
    end

    def update_dashboard(dash_id,dash)
      begin
        data = @sdk.update_dashboard(dash_id,dash)
        data&.dashboard_filters&.sort! { |a,b| a.row <=> b.row }
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard(#{dash_id},#{JSON.pretty_generate(dash)})"
        say_error e
        raise
      end
      data
    end

    def create_dashboard_element(dash_elem)
      begin
        data = @sdk.create_dashboard_element(dash_elem)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_element(#{JSON.pretty_generate(dash_elem)})"
        say_error e
        raise
      end
      data
    end

    def update_dashboard_element(id,dash_elem)
      begin
        data = @sdk.update_dashboard_element(id,dash_elem)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_element(#{id},#{JSON.pretty_generate(dash_elem)})"
        say_error e
        raise
      end
      data
    end

    def delete_dashboard_element(id)
      begin
        data = @sdk.delete_dashboard_element(id)
      rescue LookerSDK::Error => e
        say_error "Error deleting dashboard_element(#{id})})"
        say_error e
        raise
      end
      data
    end

    def get_dashboard_layout(id)
      begin
        data = @sdk.dashboard_layout(id)
      rescue LookerSDK::Error => e
        say_error "Error getting dashboard_layout(#{id})"
        say_error e
        raise
      end
      data
    end

    def create_dashboard_layout(dash_layout)
      begin
        data = @sdk.create_dashboard_layout(dash_layout)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_layout(#{JSON.pretty_generate(dash_layout)})"
        say_error e
        raise
      end
      data
    end

    def update_dashboard_layout(id,dash_layout)
      begin
        data = @sdk.update_dashboard_layout(id,dash_layout)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_layout(#{id},#{JSON.pretty_generate(dash_layout)})"
        say_error e
        raise
      end
      data
    end

    def delete_dashboard_layout(id)
      begin
        data = @sdk.delete_dashboard_layout(id)
      rescue LookerSDK::Error => e
        say_error "Error deleting dashboard_layout(#{id})"
        say_error e
        raise
      end
      data
    end

    def get_all_dashboard_layout_components(id)
      begin
        data = @sdk.dashboard_layout_dashboard_layout_components(id)
        return nil if data.respond_to?(:message) && data.message == 'Not found'
      rescue LookerSDK::Error => e
        say_error "Error getting dashboard_layout_dashboard_layout_components(#{id})"
        say_error e
        raise
      end
      data
    end

    def update_dashboard_layout_component(id,component)
      begin
        data = @sdk.update_dashboard_layout_component(id,component)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_layout_component(#{id},#{JSON.pretty_generate(component)})"
        say_error e
        raise
      end
      data
    end

    def create_dashboard_filter(dash_filter)
      begin
        data = @sdk.create_dashboard_filter(dash_filter)
      rescue LookerSDK::Error => e
        say_error "Error creating dashboard_filter(#{JSON.pretty_generate(dash_filter)})"
        say_error e
        raise
      end
      data
    end

    def update_dashboard_filter(id,dash_filter)
      begin
        data = @sdk.update_dashboard_filter(id,dash_filter)
      rescue LookerSDK::Error => e
        say_error "Error updating dashboard_filter(#{id},#{JSON.pretty_generate(dash_filter)})"
        say_error e
        raise
      end
      data
    end

    def delete_dashboard_filter(id)
      begin
        data = @sdk.delete_dashboard_filter(id)
      rescue LookerSDK::Error => e
        say_error "Error deleting dashboard_filter(#{id})})"
        say_error e
        raise
      end
      data
    end

    def cat_dashboard(dashboard_id)
      data = query_dashboard(dashboard_id).to_attrs
      data[:dashboard_elements].each_index do |i|
        element = data[:dashboard_elements][i]
        find_vis_config_reference(element) do |vis_config|
          find_color_palette_reference(vis_config) do |o,default_colors|
            rewrite_color_palette!(o,default_colors)
          end
        end
        alerts = search_alerts(fields: 'id,dashboard_element_id', group_by: 'dashboard', all_owners: true)
        alerts.map!{|v| v.to_attrs}
        say_warning alerts if @options[:debug]
        data[:dashboard_elements].each do |e|
          alerts_found = alerts.select { |a| a[:dashboard_element_id] == e[:id]}
          say_warning "Found alerts #{alerts_found}" if @options[:debug]
          alerts_entries = alerts_found.map { |a| get_alert(a[:id]).to_attrs }
          say_warning "Looked up alerts entries #{alerts_entries}" if @options[:debug]
          e[:alerts] = alerts_entries
        end

        merge_result = merge_query(element[:merge_result_id])&.to_attrs if element[:merge_result_id]
        if merge_result
          merge_result[:source_queries].each_index do |j|
            source_query = merge_result[:source_queries][j]
            merge_result[:source_queries][j][:query] = query(source_query[:query_id]).to_attrs
          end
          find_vis_config_reference(merge_result) do |vis_config|
            find_color_palette_reference(vis_config) do |o,default_colors|
              rewrite_color_palette!(o,default_colors)
            end
          end
          data[:dashboard_elements][i][:merge_result] = merge_result
        end
      end
      data[:scheduled_plans] = query_scheduled_plans_for_dashboard(@dashboard_id,"all") if @options[:plans]
      data
    end

    def trim_dashboard(data)
      trimmed = data.select do |k,v|
        (keys_to_keep('update_dashboard') + [:id,:dashboard_elements,:dashboard_filters,:dashboard_layouts,:scheduled_plans]).include? k
      end

      trimmed[:dashboard_elements] = data[:dashboard_elements].map do |de|
        new_de = de.select do |k,v|
          (keys_to_keep('update_dashboard_element') + [:id,:look,:query,:merge_result,:alerts]).include? k
        end
        if de[:look]
          new_de[:look] = de[:look].select do |k,v|
            (keys_to_keep('update_look') + [:id,:query]).include? k
          end
          if de[:look][:query]
            new_de[:look][:query] = de[:look][:query].select do |k,v|
              (keys_to_keep('create_query') + [:id]).include? k
            end
          end
        end
        if de[:query]
          new_de[:query] = de[:query].select do |k,v|
            (keys_to_keep('create_query') + [:id]).include? k
          end
        end
        if de[:merge_result]
          new_de[:merge_result] = de[:merge_result].select do |k,v|
            (keys_to_keep('update_merge_query') + [:id]).include? k
          end
          new_de[:merge_result][:source_queries] = de[:merge_result][:source_queries].map do |sq|
            sq.select do |k,v|
              (keys_to_keep('create_query') + [:id]).include? k
            end
          end
        end
        if de[:alerts]
          new_de[:alerts] = de[:alerts].map do |a|
            a.select do |k,v|
              (keys_to_keep('update_alert') + [:id,:owner]).include? k
            end
          end
        end
        new_de
      end

      trimmed[:dashboard_filters] = data[:dashboard_filters].map do |df|
        new_df = df.select do |k,v|
          keys_to_keep('update_dashboard_filter').include? k
        end
        new_df
      end

      trimmed[:dashboard_layouts] = data[:dashboard_layouts].map do |dl|
        new_dl = dl.select do |k,v|
          (keys_to_keep('update_dashboard_layout') + [:id]).include? k
        end
        if dl[:dashboard_layout_components]
          new_dl[:dashboard_layout_components] = dl[:dashboard_layout_components].map do |dlc|
            dlc.select do |k,v|
              (keys_to_keep('update_dashboard_layout_component') + [:id]).include? k
            end
          end
        end
        new_dl
      end

      trimmed[:scheduled_plans] = data[:scheduled_plans].map do |sp|
        sp.select do |k,v|
          (keys_to_keep('create_scheduled_plan') + [:id]).include? k
        end
      end if data[:scheduled_plans]

      trimmed
    end

    def import_lookml_dashboard(id,folder)
      begin
        return @sdk.import_lookml_dashboard(id,folder)&.to_attrs
      rescue LookerSDK::Error => e
        say_error "Error import_lookml_dashboard(#{id},#{folder})"
        say_error e
        raise
      end
    end

    def sync_lookml_dashboard(id)
      begin
        return @sdk.sync_lookml_dashboard(id, {})
      rescue LookerSDK::Error => e
        say_error "Error sync_lookml_dashboard(#{id})"
        say_error e
        raise
      end
    end
  end
end
