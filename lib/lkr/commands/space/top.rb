# frozen_string_literal: true

require_relative '../../command'
require 'tty-table'

module Lkr
  module Commands
    class Space
      class Top < Lkr::Command
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options.debug
          begin
            login
            spaces = all_spaces("id,name,is_shared_root,is_users_root,is_root,is_user_root,is_embed_shared_root,is_embed_users_root")

            begin
              puts "No spaces found"
              return nil
            end unless spaces && spaces.length > 0

            table = TTY::Table.new(header: spaces[0].to_attrs.keys) do |t|
              spaces.each do |h|
                t << h.to_attrs.values if (
                  h.is_shared_root || h.is_users_root || h.is_root ||
                  h.is_user_root || h.is_embed_shared_root || h.is_embed_users_root
                )
              end
            end if spaces[0]
            output.puts table.render(:ascii, alignments: [:right]) if table
          ensure
            logout_all
          end
        end
      end
    end
  end
end
