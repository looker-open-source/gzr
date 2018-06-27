# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/role'

module Gzr
  module Commands
    class Role
      class Rm < Gzr::Command
        include Gzr::Role
        def initialize(role_id,options)
          super()
          @role_id = role_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            delete_role(@plan_id)
          end
        end
      end
    end
  end
end
