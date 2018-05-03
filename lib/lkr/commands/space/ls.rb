# frozen_string_literal: true

require_relative '../../command'
require 'tty-table'

module Lkr
  module Commands
    class Space
      class Ls < Lkr::Command
        def initialize(options)
          super()
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("args: #{args.inspect}") if @options.debug
          say_warning("options: #{@options.inspect}") if @options.debug
          begin
            login
            space_ids = process_args(args)
            begin
              puts "No spaces match #{args[0]}"
              return nil
            end unless space_ids && space_ids.length > 0

            data = space_ids.map do |space_id|
              query_space(space_id, @options[:fields])
            end

            begin
              puts "No data returned for spaces #{space_ids.inspect}"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            table_hash[:header] = field_names(@options[:fields]) unless @options[:plain]
            rows = []
            data.each do |r|
              h = r.to_attrs
              rows << [h[:parent_id],h[:id],h[:name], nil, nil, nil, nil]
              h[:looks].each do |r|
                rows << [h[:parent_id],h[:id],h[:name], r[:id], r[:title], nil, nil]
              end if h[:looks]
              h[:dashboards].each do |r|
                rows << [h[:parent_id],h[:id],h[:name], nil, nil, r[:id], r[:title]]
              end if h[:dashboards]
            end
            table_hash[:rows] = rows
            table = TTY::Table.new(table_hash) if data[0]
            alignments = data[0].to_attrs.keys.map do |k|
              (k =~ /id\)*$/) ? :right : :left
            end
            puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments) if table
          ensure
            logout_all
          end
        end

        def field_names(opt_fields)
          # This is embarassingly hacky
          fields = []
          current_leader = nil
          opt_fields.split(',').each do |token|
            if /^[^\(\)]+$/.match(token)
              fields << (current_leader ? "#{current_leader}(#{token})" : token)
            else
              m = /(.*)\(([^\)]+\))/.match(token)
              if m then
                fields << token
              else
                m = /(.*)\(([^\)]+)/.match(token)
                if m then
                  current_leader = m[1]
                  fields << token + ")"
                else
                  fields << "#{current_leader}(#{token}"
                  current_leader = nil
                end
              end
            end
          end
          fields
        end
      end
    end
  end
end
