# frozen_string_literal: true

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
          with_session do
            read_file(@file) do |data|
              existing_dashboards = search_dashboards(data[:title], @dest_space_id)

              if existing_dashboards.length > 0 then
                if @options[:force] then
                  say_ok "Deleting and recreating dashboard #{data[:title]} in space #{@dest_space_id}"
                  delete_dashboard(existing_dashboards.first.id)
                else
                  say_error "Dashboard #{data[:title]} already exists in space #{@dest_space_id}"
                  return nil
                end
              end

              #new_query = data[:query].select do |k,v|
                #keys_to_keep('create_query').include? k
              #end

              new_dash = data.select do |k,v|
                keys_to_keep('create_dashboard').include? k
              end
              #new_dash[:query_id] = create_query(new_query).to_attrs[:id]
              new_dash[:user_id] = query_me("id").to_attrs[:id]
              new_dash[:space_id] = @dest_space_id
              new_dash[:dashboard_filters] = data[:dashboard_filters].map do |filter|
                filter.select do |k,v|
                  keys_to_keep('create_dashboard_filter').include? k
                end
              end

              new_dash_obj = create_dashboard(new_dash)

              elem_table = data[:dashboard_elements].map do |dash_elem|
                new_dash_elem = dash_elem.select do |k,v|
                  keys_to_keep('create_dashboard_element').include? k
                end
                
                new_dash_elem[:dashboard_id] = new_dash_obj.id

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
                      say_ok "Deleting and recreating Look #{dash_elem[:look][:title]} in space #{@dest_space_id}"
                      delete_look(existing_looks.first.id)
                    else
                      say_error "Look #{dash_elem[:look][:title]} already exists in space #{@dest_space_id}"
                      return nil
                    end
                  end

                  new_look = dash_elem[:look].select do |k,v|
                    keys_to_keep('create_look').include? k
                  end
                  new_look[:query_id] = new_query_id
                  new_look[:user_id] = new_dash[:user_id]
                  new_look[:space_id] = @dest_space_id

                  new_dash_elem[:look_id] = create_look(new_look).id
                elsif dash_elem[:query]
                  new_dash_elem[:query_id] = new_query_id
                end

                [dash_elem[:id], create_dashboard_element(new_dash_elem).id]
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
              delete_dashboard_layout(new_dash_obj.dashboard_layouts.first.id)

              data[:dashboard_filters].each do |filter|
                new_filter = filter.select do |k,v|
                  keys_to_keep('create_dashboard_filter').include? k
                end
                new_filter[:dashboard_id] = new_dash_obj.id
                #new_filter = create_dashboard_filter(new_filter)
              end
            end
          end
        end
      end
    end
  end
end
