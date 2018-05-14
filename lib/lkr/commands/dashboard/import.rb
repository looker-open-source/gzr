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

              existing_dashboards = search_dashboards(data[:title], @dest_space_id)

              if existing_dashboards.length > 0 then
                if @options[:force] then
                  say_ok "Modifying existing dashboard #{data[:title]} in space #{@dest_space_id}"
                  new_dash = data.select do |k,v|
                    (keys_to_keep('update_dashboard') - [:space_id]).include? k
                  end
                  new_dash[:user_id] = query_me("id").to_attrs[:id]
                  new_dash_obj = update_dashboard(existing_dashboards.first.id,new_dash)
                else
                  say_error "Dashboard #{data[:title]} already exists in space #{@dest_space_id}"
                  return nil
                end
              else
                new_dash = data.select do |k,v|
                  keys_to_keep('create_dashboard').include? k
                end
                new_dash[:space_id] = @dest_space_id
                new_dash_obj = create_dashboard(new_dash)
              end


              data[:dashboard_filters].each_index do |i|
                new_filter = data[:dashboard_filters][i].select do |k,v|
                  (keys_to_keep('create_dashboard_filter') + [:row]).include? k
                end
                new_filter[:dashboard_id] = new_dash_obj.id
                new_filter_obj = nil
                if new_dash_obj.dashboard_filters.length > i then
                  new_filter_obj = update_dashboard_filter(new_dash_obj.dashboard_filters[i].id,new_filter)
                else
                  new_filter_obj = create_dashboard_filter(new_filter)
                end
                new_dash_obj.dashboard_filters[i] = new_filter_obj
              end

              filters_to_delete = new_dash_obj.dashboard_filters.length - data[:dashboard_filters].length
              if filters_to_delete > 0 then
                filters_to_delete.times do
                  f = new_dash_obj.dashboard_filters.pop
                  delete_dashboard_filter(f.id)
                end
              end

              elem_table = Array.new
              data[:dashboard_elements].each_index do |i|
                dash_elem = data[:dashboard_elements][i]
                new_dash_elem_obj = nil
                if new_dash_obj.dashboard_elements.length > i then
                  new_dash_elem = dash_elem.select do |k,v|
                    keys_to_keep('update_dashboard_element').include? k
                  end
                  process_dashboard_element(new_dash_obj, dash_elem, new_dash_elem) 
                  new_dash_elem_obj = update_dashboard_element(new_dash_obj.dashboard_elements[i].id,new_dash_elem)
                else
                  new_dash_elem = dash_elem.select do |k,v|
                    keys_to_keep('create_dashboard_element').include? k
                  end
                  new_dash_elem[:dashboard_id] = new_dash_obj.id
                  process_dashboard_element(new_dash_obj, dash_elem, new_dash_elem) 
                  new_dash_elem_obj = create_dashboard_element(new_dash_elem)
                end
                elem_table << [dash_elem[:id], new_dash_elem_obj.id]
              end

              elements_to_delete = new_dash_obj.dashboard_elements.length - data[:dashboard_elements].length
              if elements_to_delete > 0 then
                elements_to_delete.times do
                  e = new_dash_obj.dashboard_elements.pop
                  delete_dashboard_element(e.id)
                end
              end

              layout_table = data[:dashboard_layouts].map do |layout|
                new_layout = layout.select do |k,v|
                  keys_to_keep('create_dashboard_layout').include? k
                end

                new_layout[:dashboard_id] = new_dash_obj.id 

                [layout,create_dashboard_layout(new_layout).to_attrs]
              end

              layout_table.each do |orig_layout,new_layout|
                elem_table.each do |orig_elem_id,new_elem_id|
                  orig_component = orig_layout[:dashboard_layout_components].select { |c| c[:dashboard_element_id] == orig_elem_id }.first
                  new_component = new_layout[:dashboard_layout_components].select { |c| c[:dashboard_element_id] == new_elem_id }.first
                  updated_component = orig_component.select do |k,v|
                    keys_to_keep('update_dashboard_layout_component').include? k
                  end
                  updated_component[:dashboard_layout_id] = new_layout[:id]
                  updated_component[:dashboard_element_id] = new_elem_id
                  update_dashboard_layout_component(new_component[:id],updated_component)
                end
                update_dashboard_layout(new_layout[:id], active: true) if orig_layout[:active]
              end
              new_dash_obj.dashboard_layouts.each do |layout|
                delete_dashboard_layout(layout.id)
              end
            end
          end
        end

        def process_dashboard_element(new_dash_obj,dash_elem,new_dash_elem)
          if dash_elem[:query] || dash_elem[:look] then
            new_query = (dash_elem[:query]||dash_elem[:look][:query]).select do |k,v|
              keys_to_keep('create_query').include? k
            end 
            new_query[:client_id] = nil
            new_query_id = create_query(new_query).id
          end

          if dash_elem[:look] then
            existing_looks = search_looks(dash_elem[:look][:title], @dest_space_id)

            if existing_looks.length > 0 then
              if @options[:force] then
                say_ok "Modifying existing Look #{dash_elem[:look][:title]} in space #{@dest_space_id}"
                new_look = dash_elem[:look].select do |k,v|
                  (keys_to_keep('update_look') - [:space_id]).include? k
                end
                new_look[:query_id] = new_query_id
                new_look[:user_id] = new_dash_obj.user_id

                new_dash_elem[:look_id] = update_look(existing_looks.first.id,new_look).id
              else
                say_error "Look #{dash_elem[:look][:title]} already exists in space #{@dest_space_id}"
                return nil
              end
            else
              new_look = dash_elem[:look].select do |k,v|
                keys_to_keep('create_look').include? k
              end
              new_look[:query_id] = new_query_id
              new_look[:user_id] = new_dash_obj.user_id
              new_look[:space_id] = @dest_space_id

              new_dash_elem[:look_id] = create_look(new_look).id
            end
          elsif dash_elem[:query]
            new_dash_elem[:query_id] = new_query_id
          end
        end
      end
    end
  end
end
