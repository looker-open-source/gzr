# frozen_string_literal: true

require_relative '../../../lkr'
require_relative '../../command'
require_relative '../../modules/dashboard'
require_relative '../../modules/look'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Lkr
  module Commands
    class Dashboard
      class Import < Lkr::Command
        include Lkr::Dashboard
        include Lkr::Look
        include Lkr::User
        include Lkr::FileHelper
        def initialize(file, dest_space_id, options)
          super()
          @file = file
          @dest_space_id = dest_space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session("3.1") do
            read_file(@file) do |data|

              new_dash_obj = nil
              me = query_me("id")

              existing_dashboard = search_dashboards(data[:title], @dest_space_id).fetch(0,nil)

              if existing_dashboard then
                if @options[:force] then
                  say_ok "Modifying existing dashboard #{existing_dashboard.id} #{data[:title]} in space #{@dest_space_id}"
                  new_dash = data.select do |k,v|
                    (keys_to_keep('update_dashboard') - [:space_id,:user_id]).include? k
                  end
                  new_dash_obj = update_dashboard(existing_dashboard.id,new_dash)
                else
                  raise Lkr::Error, "Dashboard #{data[:title]} already exists in space #{@dest_space_id}\nUse --force if you want to overwrite it"
                end
              else
                new_dash = data.select do |k,v|
                  (keys_to_keep('create_dashboard') - [:space_id,:user_id]).include? k
                end
                new_dash[:space_id] = @dest_space_id
                new_dash[:user_id] = me.id
                new_dash_obj = create_dashboard(new_dash)
              end


              filters = Array.new([data[:dashboard_filters].count,new_dash_obj.dashboard_filters.count].max) do |i|
                [data[:dashboard_filters].fetch(i,nil),new_dash_obj.dashboard_filters.fetch(i,nil)]
              end

              filters.each do |new_filter,existing_filter|
                if new_filter then
                  filter = new_filter.select do |k,v|
                    (keys_to_keep('create_dashboard_filter') + [:row]).include? k
                  end
                  filter[:dashboard_id] = new_dash_obj.id
                  if existing_filter then
                    say_warning "Updating filter #{existing_filter.id}" if @options[:debug]
                    new_filter_obj = update_dashboard_filter(existing_filter.id,filter)
                  else
                    say_warning "Creating filter #{filter.inspect}" if @options[:debug]
                    new_filter_obj = create_dashboard_filter(filter)
                  end
                else
                  say_warning "Deleting filter #{existing_filter.id}" if @options[:debug]
                  delete_dashboard_filter(existing_filter.id)
                end
              end

              elements = Array.new([data[:dashboard_elements].count,new_dash_obj.dashboard_elements.count].max) do |i|
                [data[:dashboard_elements].fetch(i,nil),new_dash_obj.dashboard_elements.fetch(i,nil)]
              end

              say_warning "Processing #{elements.count} dashboard elements" if @options[:debug]

              elem_table = elements.collect do |new_element,existing_element|
                if new_element then
                  if existing_element then
                    new_dash_elem = new_element.select do |k,v|
                      (keys_to_keep('update_dashboard_element') - [:dashboard_id, :look_id, :query_id]).include? k
                    end
                    process_dashboard_element(new_dash_obj, new_element, new_dash_elem) 
                    say_warning "Updating dashboard element #{existing_element.id}" if @options[:debug]
                    new_dash_elem_obj = update_dashboard_element(existing_element.id,new_dash_elem)
                  else
                    new_dash_elem = new_element.select do |k,v|
                      (keys_to_keep('create_dashboard_element') - [:dashboard_id, :look_id, :query_id]).include? k
                    end
                    process_dashboard_element(new_dash_obj, new_element, new_dash_elem) 
                    say_warning "Creating dashboard element #{new_dash_elem.inspect}" if @options[:debug]
                    new_dash_elem[:dashboard_id] = new_dash_obj.id
                    new_dash_elem_obj = create_dashboard_element(new_dash_elem)
                  end
                  [new_element[:id],new_dash_elem_obj.id]
                else
                  say_warning "Deleting dashboard element #{existing_element.id}" if @options[:debug]
                  delete_dashboard_element(existing_element.id)
                  [nil,existing_element.id]
                end
              end

              layouts = Array.new([data[:dashboard_layouts].count,new_dash_obj.dashboard_layouts.count].max) do |i|
                [data[:dashboard_layouts].fetch(i,nil),new_dash_obj.dashboard_layouts.fetch(i,nil)]
              end

              layouts.each do |new_layout,existing_layout|
                if new_layout then
                  new_layout_obj = nil
                  if existing_layout then
                    layout = new_layout.select do |k,v|
                      (keys_to_keep('update_dashboard_layout') - [:dashboard_id,:active]).include? k
                    end
                    layout[:active] = true if new_layout[:active]
                    say_warning "Updating dashboard layout #{existing_layout.id}" if @options[:debug]
                    new_layout_obj = update_dashboard_layout(existing_layout.id,layout)
                  else
                    layout = new_layout.select do |k,v|
                      (keys_to_keep('create_dashboard_layout') - [:dashboard_id,:active]).include? k
                    end
                    layout[:active] = true if new_layout[:active]
                    layout[:dashboard_id] = new_dash_obj.id 
                    say_warning "Creating dashboard layout #{layout}" if @options[:debug]
                    new_layout_obj = create_dashboard_layout(layout)
                  end

                  layout_components = new_layout[:dashboard_layout_components].zip(new_layout_obj.dashboard_layout_components)
                  
                  layout_components.each do |new_component, existing_component|
                    component = keys_to_keep('update_dashboard_layout_component').collect do |e|
                      [e,nil]
                    end.to_h
                    component[:dashboard_layout_id] = new_layout_obj.id

                    component.merge!(new_component.select do |k,v|
                      (keys_to_keep('update_dashboard_layout_component') - [:id,:dashboard_layout_id]).include? k
                    end)

                    component[:dashboard_element_id] = elem_table.assoc(new_component[:dashboard_element_id])[1]
                    say_warning "Updating dashboard layout component #{existing_component.id}" if @options[:debug]
                    update_dashboard_layout_component(existing_component.id,component)
                  end
                else
                  say_warning "Deleting dashboard layout #{existing_layout.id}" if @options[:debug]
                  delete_dashboard_layout(layout.id)
                end
              end
            end
          end
        end

        def process_dashboard_element(new_dash_obj,dash_elem,new_dash_elem)
          return unless dash_elem[:query] || dash_elem[:look]
          new_query = create_fetch_query(dash_elem[:query]||dash_elem[:look][:query])

          if dash_elem[:look] then
            new_dash_elem[:look_id] = upsert_look(new_dash_obj.user_id, new_query.id, @dest_space_id, dash_elem[:look]).id
          elsif dash_elem[:query]
            new_dash_elem[:query_id] = new_query.id
          end
        end
      end
    end
  end
end
