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
        def initialize(file, dest_folder_id, options)
          super()
          @file = file
          @dest_folder_id = dest_folder_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}", output: output) if @options[:debug]
          with_session do

            @me ||= query_me("id")

            read_file(@file) do |data|

              if data[:deleted]
                say_warning("Attempt to import a deleted dashboard!")
                say_warning("This may result in errors.")
              end

              if !data[:dashboard_elements]
                say_error("File contains no dashboard_elements! Is this a look?")
                raise Gzr::CLI::Error, "import file is not a valid dashboard"
              end

              dashboard = sync_dashboard(data,@dest_folder_id, output: output)
              say_warning "dashboard object #{JSON.pretty_generate dashboard.map(&:to_a).to_json}" if @options[:debug]

              dashboard[:dashboard_filters] ||= []
              source_filters = data[:dashboard_filters].sort { |a,b| a[:row] <=> b[:row] }
              source_filters.each do |new_filter|
                filter = new_filter.select do |k,v|
                  (keys_to_keep('create_dashboard_filter') + [:row]).include? k
                end
                filter[:dashboard_id] = dashboard[:id]
                say_warning "Creating filter" if @options[:debug]
                dashboard[:dashboard_filters].push create_dashboard_filter(filter)
              end

              dashboard[:dashboard_elements] ||= []
              elem_table = data[:dashboard_elements].map do |new_element|
                element = new_element.select do |k,v|
                  (keys_to_keep('create_dashboard_element') - [:dashboard_id, :look_id, :query_id, :merge_result_id, :result_maker_id, :query, :merge_result]).include? k
                end
                (element[:query_id],element[:look_id],element[:merge_result_id]) = process_dashboard_element(new_element)
                say_warning "Creating dashboard element #{element.select {|k,v| !v.nil?}.inspect}" if @options[:debug]
                element[:dashboard_id] = dashboard[:id]
                result_maker = copy_result_maker_filterables(new_element)
                element[:result_maker] = result_maker if result_maker
                dashboard_element = create_dashboard_element(element)
                say_warning "dashboard_element #{dashboard_element.inspect}" if @options[:debug]
                if new_element[:alerts]
                  new_element[:alerts].each do |a|
                    a.select! do |k,v|
                      (keys_to_keep('create_alert') - [:owner_id, :dashboard_element_id]).include? k
                    end
                    a[:dashboard_element_id] = dashboard_element[:id]
                    a[:owner_id] = @me[:id]
                    new_alert = create_alert(a)
                    say_warning "alert #{JSON.pretty_generate(new_alert)}" if @options[:debug]
                  end
                end
                dashboard[:dashboard_elements].push dashboard_element
                [new_element[:id], dashboard_element[:id]]
              end

              source_dashboard_layouts = data[:dashboard_layouts].map do |new_layout|
                layout_obj = nil
                if new_layout[:active]
                  layout_obj = get_dashboard_layout(dashboard[:dashboard_layouts].first[:id])
                  say_warning "Updating layout #{layout_obj[:id]}" if @options[:debug]
                else
                  layout = new_layout.select do |k,v|
                    (keys_to_keep('create_dashboard_layout') - [:dashboard_id]).include? k
                  end
                  layout[:dashboard_id] = dashboard[:id]
                  say_warning "Creating dashboard layout #{layout}" if @options[:debug]
                  layout_obj = create_dashboard_layout(layout)
                  say_warning "Created dashboard layout #{JSON.pretty_generate layout_obj.map(&:to_a).to_json}" if @options[:debug]
                end
                layout_components = new_layout[:dashboard_layout_components].zip(layout_obj.dashboard_layout_components)
                layout_components.each do |source,target|
                  component = keys_to_keep('update_dashboard_layout_component').collect do |e|
                    [e,nil]
                  end.to_h
                  component[:dashboard_layout_id] = target[:dashboard_layout_id]

                  component.merge!(source.select do |k,v|
                    (keys_to_keep('update_dashboard_layout_component') - [:id,:dashboard_layout_id]).include? k
                  end)

                  component[:dashboard_element_id] = elem_table.assoc(source[:dashboard_element_id])[1]
                  say_warning "Updating dashboard layout component #{target[:id]}" if @options[:debug]
                  update_dashboard_layout_component(target[:id],component)
                end
              end
              upsert_plans_for_dashboard(dashboard.id,@me[:id],data[:scheduled_plans]) if data[:scheduled_plans]
              output.puts "Imported dashboard #{dashboard[:id]}" unless @options[:plain]
              output.puts dashboard.id if @options[:plain]
            end
          end
        end

        def sync_dashboard(source, target_folder_id, output: $stdout)
          # try to find dashboard by slug in target folder
          existing_dashboard = search_dashboards_by_slug(source[:slug], target_folder_id).fetch(0,nil) if source[:slug]
          # check for dash of same title in target folder
          title_used = search_dashboards_by_title(source[:title], target_folder_id).select {|d| !d[:deleted] }.fetch(0,nil)
          # If there is no match by slug in target folder or no slug given, then we match by title
          existing_dashboard ||= title_used
          say_warning "existing_dashboard object #{existing_dashboard.inspect}" if @options[:debug]

          # same_title is now a flag indicating that there is already a dash in the same folder with
          # that title, and it is the one we are updating.
          same_title = (title_used&.fetch(:id,nil) == existing_dashboard&.fetch(:id,nil))

          # check if the slug is used by any dashboard
          slug_used = search_dashboards_by_slug(source[:slug]).fetch(0,nil) if source[:slug]

          # same_slug is now a flag indicating that there is already a dash with
          # that slug, but it is the one we are updating.
          same_slug = (slug_used&.fetch(:id,nil) == existing_dashboard&.fetch(:id,nil))

          if slug_used && !same_slug then
            say_warning "slug #{slug_used[:slug]} already used for dashboard #{slug_used[:title]} in folder #{slug_used[:folder_id]}", output: output
            say_warning("That dashboard is in the 'Trash' but not fully deleted yet", output: output) if slug_used[:deleted]
            say_warning "dashboard will be imported with new slug", output: output
          end

          if existing_dashboard then
            if title_used && !same_title then
              raise Gzr::CLI::Error, "Dashboard #{source[:title]} already exists in folder #{target_folder_id}\nDelete it before trying to upate another dashboard to have that title."
            end
            raise Gzr::CLI::Error, "Dashboard #{existing_dashboard[:title]} with slug #{existing_dashboard[:slug]} already exists in folder #{target_folder_id}\nUse --force if you want to overwrite it" unless @options[:force]

            say_ok "Modifying existing dashboard #{existing_dashboard[:id]} #{existing_dashboard[:title]} in folder #{target_folder_id}", output: output
            new_dash = source.select do |k,v|
              (keys_to_keep('update_dashboard') - [:space_id,:folder_id,:user_id,:slug]).include? k
            end
            new_dash[:slug] = source[:slug] unless slug_used
            new_dash[:deleted] = false if existing_dashboard[:deleted]
            d = update_dashboard(existing_dashboard[:id],new_dash)

            d[:dashboard_filters].each do |f|
              delete_dashboard_filter(f[:id])
            end
            d[:dashboard_filters] = []

            d[:dashboard_elements].each do |e|
              delete_dashboard_element(e[:id])
            end
            d[:dashboard_elements] = []

            d[:dashboard_layouts].each do |l|
              delete_dashboard_layout(l[:id]) unless l[:active]
            end
            d[:dashboard_layouts].select! { |l| l[:active] }

            return d
          else
            new_dash = source.select do |k,v|
              (keys_to_keep('create_dashboard') - [:space_id,:folder_id,:user_id,:slug]).include? k
            end
            new_dash[:slug] = source[:slug] unless slug_used
            new_dash[:folder_id] = target_folder_id
            new_dash[:user_id] = @me[:id]
            new_dash.select!{|k,v| !v.nil?}
            say_warning "new dashboard request #{new_dash.inspect}" if @options[:debug]
            d = create_dashboard(new_dash)
            say_warning "new dashboard object #{d.inspect}" if @options[:debug]
            return d
          end
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

        def process_dashboard_element(dash_elem)
          return [nil, upsert_look(@me[:id], create_fetch_query(dash_elem[:look][:query])[:id], @dest_folder_id, dash_elem[:look])[:id], nil] if dash_elem[:look]

          query = dash_elem[:result_maker]&.fetch(:query, false) || dash_elem[:query]
          return [create_fetch_query(query).id, nil, nil] if query

          merge_result = dash_elem[:result_maker]&.fetch(:merge_result, false) || dash_elem[:merge_result]
          return [nil,nil,create_merge_result(merge_result)[:id]] if merge_result

          [nil,nil,nil]
        end

      end
    end
  end
end
