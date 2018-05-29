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

              dashboard_filters(data[:dashboard_filters],dashboard) do |id,source,target|
                sync_dashboard_filter(id,source,target)
              end

              elem_table = dashboard_elements(data[:dashboard_elements],dashboard) do |id,source,target|
                sync_dashboard_element(id,source,target)
              end

              dashboard_layouts(data[:dashboard_layouts],dashboard) do |s,t|
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
          existing_dashboard = search_dashboards(source[:title], target_space_id).fetch(0,nil)

          if existing_dashboard then
            if @options[:force] then
              say_ok "Modifying existing dashboard #{existing_dashboard.id} #{existing_dashboard[:title]} in space #{target_space_id}"
              new_dash = source.select do |k,v|
                (keys_to_keep('update_dashboard') - [:space_id,:user_id,:title]).include? k
              end
              return update_dashboard(existing_dashboard.id,new_dash)
            else
              raise Gzr::CLI::Error, "Dashboard #{source[:title]} already exists in space #{target_space_id}\nUse --force if you want to overwrite it"
            end
          else
            new_dash = source.select do |k,v|
              (keys_to_keep('create_dashboard') - [:space_id,:user_id]).include? k
            end
            new_dash[:space_id] = target_space_id
            new_dash[:user_id] = @me.id
            return create_dashboard(new_dash)
          end
        end

        def dashboard_filters(source,target)
          filters = Array.new([source.count,target.dashboard_filters.count].max) do |i|
            [target.id,source.fetch(i,nil),target.dashboard_filters.fetch(i,nil)]
          end

          return filters unless block_given?

          filters.each { |i,s,t| yield(i,s,t) }
        end

        def sync_dashboard_filter(dashboard_id,new_filter,existing_filter)
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

        def dashboard_elements(source,target)
          elements = Array.new([source.count,target.dashboard_elements.count].max) do |i|
            [target.id,source.fetch(i,nil),target.dashboard_elements.fetch(i,nil)]
          end

          say_warning "Processing #{elements.count} dashboard elements" if @options[:debug]

          return elements unless block_given?

          return elements.collect { |i,s,t| yield(i,s,t) }
        end


        def sync_dashboard_element(dashboard_id,new_element,existing_element)
          if new_element && !existing_element then
            element = new_element.select do |k,v|
              (keys_to_keep('create_dashboard_element') - [:dashboard_id, :look_id, :query_id, :merge_result_id]).include? k
            end
            (element[:query_id],element[:look_id]) = process_dashboard_element(new_element) 
            say_warning "Creating dashboard element #{element.inspect}" if @options[:debug]
            element[:dashboard_id] = dashboard_id
            return [new_element[:id], create_dashboard_element(element).id]
          end
          if existing_element && new_element then
            element = keys_to_keep('update_dashboard_element').collect do |e|
              [e,nil]
            end.to_h

            element.merge!( new_element.select do |k,v|
              (keys_to_keep('update_dashboard_element') - [:dashboard_id, :look_id, :query_id, :merge_result_id]).include? k
            end
            )
            (element[:query_id],element[:look_id]) = process_dashboard_element(new_element) 
            say_warning "Updating dashboard element #{existing_element.id}" if @options[:debug]
            return [new_element[:id], update_dashboard_element(existing_element.id,element).id]
          end
          say_warning "Deleting dashboard element #{existing_element.id}" if @options[:debug]
          delete_dashboard_element(existing_element.id)
          return [nil,existing_element.id]
        end

        def process_dashboard_element(dash_elem)
          return [create_fetch_query(dash_elem[:query]).id, nil] if dash_elem[:query]
          return [nil, upsert_look(@me.id, create_fetch_query(dash_elem[:look][:query]).id, @dest_space_id, dash_elem[:look]).id] if dash_elem[:look]
          [nil,nil]
        end

        def dashboard_layouts(source,target)
          layouts = Array.new([source.count,target.dashboard_layouts.count].max) do |i|
            [source.fetch(i,nil),target.dashboard_layouts.fetch(i,nil)]
          end

          return layouts unless block_given?

          layouts.each { |s,t| yield(s,t) }
        end

        def sync_dashboard_layout(dashboard_id,new_layout,existing_layout)
          layout_obj = nil
          if new_layout && !existing_layout then
            layout = new_layout.select do |k,v|
              (keys_to_keep('create_dashboard_layout') - [:dashboard_id,:active]).include? k
            end
            layout[:active] = true if new_layout[:active]
            layout[:dashboard_id] = dashboard_id
            say_warning "Creating dashboard layout #{layout}" if @options[:debug]
            layout_obj = create_dashboard_layout(layout)
          end
          if new_layout && existing_layout then
            layout = new_layout.select do |k,v|
              (keys_to_keep('update_dashboard_layout') - [:dashboard_id,:active]).include? k
            end
            layout[:active] = true if new_layout[:active]
            say_warning "Updating dashboard layout #{existing_layout.id}" if @options[:debug]
            layout_obj = update_dashboard_layout(existing_layout.id,layout)
          end
          if !new_layout && exisiting_layout then
            say_warning "Deleting dashboard layout #{existing_layout.id}" if @options[:debug]
            delete_dashboard_layout(existing_layout.id)
          end

          return unless layout_obj

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
