# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/space'
require 'tty-table'

module Gzr
  module Commands
    class Space
      class Ls < Gzr::Command
        include Gzr::Space
        def initialize(filter_spec, options)
          super()
          @filter_spec = filter_spec
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            space_ids = process_args([@filter_spec])
            begin
              puts "No spaces match #{@filter_spec}"
              return nil
            end unless space_ids && space_ids.length > 0

            data = space_ids.map do |space_id|
              query_space(space_id, @options[:fields])
            end

            begin
              puts "No data returned for spaces #{space_ids.inspect}"
              return nil
            end unless data && data.length > 0

            @options[:fields] = 'dashboards(id,title)' if @filter_spec == 'lookml'
            table_hash = Hash.new
            fields = field_names(@options[:fields])
            table_hash[:header] = field_names(@options[:fields]) unless @options[:plain]
            rows = []
            data.each do |r|
              h = r.to_attrs
              if @filter_spec != 'lookml' then
                rows << [h[:parent_id],h[:id],h[:name], nil, nil, nil, nil]
                subspaces = query_space_children(h[:id], "id,name,parent_id")
                rows += subspaces.map do |r|
                  h1 = r.to_attrs
                  [h1[:parent_id], h1[:id], h1[:name], nil, nil, nil, nil]
                end
              end
              h[:looks].each do |r|
                rows << [h[:parent_id],h[:id],h[:name], r[:id], r[:title], nil, nil]
              end if h[:looks]
              h[:dashboards].each do |r|
                rows << [h[:parent_id],h[:id],h[:name], nil, nil, r[:id], r[:title]] unless @filter_spec == 'lookml'
                rows << [r[:id], r[:title]] if @filter_spec == 'lookml'
              end if h[:dashboards]
            end
            table_hash[:rows] = rows
            table = TTY::Table.new(table_hash) if data[0]
            alignments = fields.collect do |k|
              (k =~ /id\)*$/) ? :right : :left
            end
            begin
              if @options[:csv] then
                output.puts render_csv(table)
              else
                output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments)
              end
            end if table
          end
        end
      end
    end
  end
end
