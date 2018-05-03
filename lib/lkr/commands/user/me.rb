# frozen_string_literal: true

require_relative '../../command'
require 'tty-table'

module Lkr
  module Commands
    class User
      class Me < Lkr::Command
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options.debug
          begin
            login
            data = query_me(@options[:fields])
            table_hash = Hash.new
            table_hash[:header] = data.to_attrs.keys unless @options[:plain]
            table_hash[:rows] = [data.to_attrs.values]
            table = TTY::Table.new(table_hash) if data
            alignments = data.to_attrs.keys.map do |k|
              (k =~ /id$/) ? :right : :left
            end
            puts table.render(if @options.plain then :basic else :ascii end, alignments: alignments) if table
          ensure
            logout_all
          end
        end
      end
    end
  end
end
