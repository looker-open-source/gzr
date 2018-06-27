# frozen_string_literal: true

require_relative '../../command'

module Gzr
  module Commands
    class Role
      class UserLs < Gzr::Command
        def initialize(options)
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          # Command logic goes here ...
          output.puts "OK"
        end
      end
    end
  end
end
