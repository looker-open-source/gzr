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

require_relative '../../../gzr'
require_relative '../../command'
require_relative '../../modules/dashboard'
require_relative '../../modules/look'
require_relative '../../modules/user'
require_relative '../../modules/plan'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Dashboard
      class Import < Gzr::Command
        include Gzr::Dashboard
        include Gzr::Look
        include Gzr::User
        include Gzr::Plan
        include Gzr::FileHelper
        def initialize(file, dest_space_id, options)
          super()
          @file = file
          @dest_space_id = dest_space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session("3.1") do

            @me ||= query_me("id")

            read_file(@file) do |data|

              dashboard = sync_dashboard(data,@dest_space_id)

              source_filters = data[:dashboard_filters].sort { |a,b| a[:row] <=> b[:row] }
              existing_filters = dashboard.dashboard_filters.sort { |a,b| a.row <=> b.row }
              existing_filters.collect! do |e|
                matches_by_name_title = source_filters.select { |s| s[:row] != e.row && (s[:title] == e.title || s[:name] == e.name) }
                if matches_by_name_title.length > 0
                  delete_dashboard_filter(e.id)
                  nil
                else
                  e
                end
              end
              pairs(source_filters,existing_filters,dashboard.id) do |source,target,id|
                say_warning "Synching dashboard filter for dashboard #{id}" if @options[:debug]
                sync_dashboard_filter(source,target,id)
              end

              elem_table = pairs(data[:dashboard_elements],dashboard.dashboard_elements,dashboard.id) do |source,target,id|
                sync_dashboard_element(source,target,id)
              end

              source_dashboard_layouts = data[:dashboard_layouts].sort_by { |v| (v[:active] ? 0 : 1) }
              existing_dashboard_layouts = dashboard.dashboard_layouts.sort_by { |v| (v.active ? 0 : 1) }
              pairs(source_dashboard_layouts,existing_dashboard_layouts) do |s,t|
                sync_dashboard_layout(dashboard.id,s,t) do |s,t|
                  sync_dashboard_layout_component(s,t,elem_table)
                end
              end
              upsert_plans_for_dashboard(dashboard.id,@me.id,data[:scheduled_plans]) if data[:scheduled_plans]
              output.puts "Imported dashboard #{dashboard.id}" unless @options[:plain] 
              output.puts dashboard.id if @options[:plain] 
            end
          end
        end

        def sync_dashboard(source,target_space_id)
          slug_used = search_dashboards_by_slug(source[:slug]).fetch(0,nil) if source[:slug]
          title_used = search_dashboards_by_title(source[:title], target_space_id).fetch(0,nil)
          existing_dashboard = search_dashboards_by_slug(source[:slug], target_space_id).fetch(0,nil) if source[:slug]
          if existing_dashboard then
            title_used = false if title_used && title_used.id == existing_dashboard.id
          else
            existing_dashboard = title_used
            title_used = false
          end
          slug_used = false if existing_dashboard && slug_used && slug_used.id == existing_dashboard.id

          if slug_used then
            say_warning "slug #{slug_used.slug} already used for dashboard #{slug_used.title} in space #{slug_used.space_id}"
            say_warning "dashboard will be imported with new slug"
          end

          if existing_dashboard then
            if title_used then
              raise Gzr::CLI::Error, "Dashboard #{source[:title]} already exists in space #{target_space_id}\nDelete it before trying to upate another dashboard to have that title."
            end
            if @options[:force] then
              say_ok "Modifying existing dashboard #{existing_dashboard.id} #{existing_dashboard[:title]} in space #{target_space_id}"
              new_dash = source.select do |k,v|
                (keys_to_keep('update_dashboard') - [:space_id,:user_id,:slug]).include? k
              end
              new_dash[:slug] = source[:slug] unless slug_used
              return update_dashboard(existing_dashboard.id,new_dash)
            else
              raise Gzr::CLI::Error, "Dashboard #{source[:title]} already exists in space #{target_space_id}\nUse --force if you want to overwrite it"
            end
          else
            new_dash = source.select do |k,v|
              (keys_to_keep('create_dashboard') - [:space_id,:user_id,:slug]).include? k
            end
            new_dash[:slug] = source[:slug] unless slug_used
            new_dash[:space_id] = target_space_id
            new_dash[:user_id] = @me.id
            return create_dashboard(new_dash)
          end
        end

        def sync_dashboard_filter(new_filter,existing_filter,dashboard_id)
          if new_filter && !existing_filter then
            filter = new_filter.select do |k,v|
              (keys_to_keep('create_dashboard_filter') + [:row]).include? k
            end
            filter[:dashboard_id] = dashboard_id
            say_warning "Creating filter" if @options[:debug]
            return create_dashboard_filter(filter)
          end
          if existing_filter && new_filter then
            filter = new_filter.select do |k,v|
              (keys_to_keep('update_dashboard_filter') + [:row]).include? k
            end
            say_warning "Updating filter #{existing_filter.id}" if @options[:debug]
            return update_dashboard_filter(existing_filter.id,filter)
          end
          say_warning "Deleting filter #{existing_filter.id}" if @options[:debug]
          return delete_dashboard_filter(existing_filter.id)
        end

        def copy_result_maker_filterables(new_element)
          return nil unless new_element[:result_maker]
          if new_element[:result_maker].fetch(:filterables,[]).length > 0
            result_maker = { :filterables => [] }
            new_element[:result_maker][:filterables].each do |filterable|
              result_maker[:filterables] << filterable.select do |k,v|
                true unless [:can].include? k
              end
            end
            return result_maker
          end
          nil
        end

        def sync_dashboard_element(new_element,existing_element,dashboard_id)
          if new_element && !existing_element then
            element = new_element.select do |k,v|
              (keys_to_keep('create_dashboard_element') - [:dashboard_id, :look_id, :query_id, :merge_result_id]).include? k
            end
            (element[:query_id],element[:look_id],element[:merge_result_id]) = process_dashboard_element(new_element) 
            say_warning "Creating dashboard element #{element.inspect}" if @options[:debug]
            element[:dashboard_id] = dashboard_id
            result_maker = copy_result_maker_filterables(new_element)
            element[:result_maker] = result_maker if result_maker
            return [new_element[:id], create_dashboard_element(element).id]
          end
          if existing_element && new_element then
            element = keys_to_keep('update_dashboard_element').collect do |e|
              [e,nil]
            end.to_h

            element[:dashboard_id] = dashboard_id

            element.merge!( new_element.select do |k,v|
              (keys_to_keep('update_dashboard_element') - [:dashboard_id, :look_id, :query_id, :merge_result_id]).include? k
            end
            )
            (element[:query_id],element[:look_id],element[:merge_result_id]) = process_dashboard_element(new_element) 
            say_warning "Updating dashboard element #{existing_element.id}" if @options[:debug]
            result_maker = copy_result_maker_filterables(new_element)
            element[:result_maker] = result_maker if result_maker
            return [new_element[:id], update_dashboard_element(existing_element.id,element).id]
          end
          say_warning "Deleting dashboard element #{existing_element.id}" if @options[:debug]
          delete_dashboard_element(existing_element.id)
          return [nil,existing_element.id]
        end

        def process_dashboard_element(dash_elem)
          return [create_fetch_query(dash_elem[:query]).id, nil, nil] if dash_elem[:query]
          return [nil, upsert_look(@me.id, create_fetch_query(dash_elem[:look][:query]).id, @dest_space_id, dash_elem[:look]).id, nil] if dash_elem[:look]
          return [nil,nil,create_merge_result(dash_elem[:merge_result]).id] if dash_elem[:merge_result]
          [nil,nil,nil]
        end

        def sync_dashboard_layout(dashboard_id,new_layout,existing_layout)
          layout_obj = nil
          if new_layout && !existing_layout then
            layout = new_layout.select do |k,v|
              (keys_to_keep('create_dashboard_layout') - [:dashboard_id]).include? k
            end
            layout[:dashboard_id] = dashboard_id
            say_warning "Creating dashboard layout #{layout}" if @options[:debug]
            layout_obj = create_dashboard_layout(layout)
          end
          if new_layout && existing_layout then
            layout = new_layout.select do |k,v|
              (keys_to_keep('update_dashboard_layout') - [:dashboard_id]).include? k
            end
            say_warning "Updating dashboard layout #{existing_layout.id}" if @options[:debug]
            layout_obj = update_dashboard_layout(existing_layout.id,layout)
          end
          if !new_layout && existing_layout then
            say_warning "Deleting dashboard layout #{existing_layout.id}" if @options[:debug]
            delete_dashboard_layout(existing_layout.id)
          end

          return unless layout_obj

          #say_warning "new_layout[:active] is #{new_layout&.fetch(:active)} for #{layout_obj.id}"
          #if layout_obj && new_layout&.fetch(:active,false)
          #  say_warning "Setting layout #{layout_obj.id} active"
          #  update_dashboard_layout(layout_obj.id, { :active => true })
          #end

          layout_components = new_layout[:dashboard_layout_components].zip(layout_obj.dashboard_layout_components)
          return layout_components unless block_given?

          layout_components.each { |s,t| yield(s,t) }
        end

        def sync_dashboard_layout_component(source, target, elem_table)
          component = keys_to_keep('update_dashboard_layout_component').collect do |e|
            [e,nil]
          end.to_h
          component[:dashboard_layout_id] = target.dashboard_layout_id

          component.merge!(source.select do |k,v|
            (keys_to_keep('update_dashboard_layout_component') - [:id,:dashboard_layout_id]).include? k
          end)

          component[:dashboard_element_id] = elem_table.assoc(source[:dashboard_element_id])[1]
          say_warning "Updating dashboard layout component #{target.id}" if @options[:debug]
          update_dashboard_layout_component(target.id,component)
        end
      end
    end
  end
end
