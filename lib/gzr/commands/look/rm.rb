# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/look'

module Gzr
  module Commands
    class Look
      class Rm < Gzr::Command
        include Gzr::Look
        def initialize(look_id, options)
          super()
          @look_id = look_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
            with_session do
            delete_look(@look_id)
          end
        end
      end
    end
  end
end
