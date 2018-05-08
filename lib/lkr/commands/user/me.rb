# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/user'
require 'tty-table'

module Lkr
  module Commands
    class User
      class Me < Lkr::Command
        include Lkr::User

        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = query_me(@options[:fields])
            table_hash = Hash.new
            table_hash[:header] = data.to_attrs.keys unless @options[:plain]
            table_hash[:rows] = [data.to_attrs.values]
            table = TTY::Table.new(table_hash) if data
            alignments = data.to_attrs.keys.map do |k|
              (k =~ /id$/) ? :right : :left
            end
            output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments) if table
          end
        end
      end
    end
  end
end
