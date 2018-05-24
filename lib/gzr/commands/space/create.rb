# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/space'

module Gzr
  module Commands
    class Space
      class Create < Gzr::Command
        include Gzr::Space
        def initialize(name,parent_space, options)
          super()
          @name = name
          @parent_space = parent_space
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          with_session do
            create_space(@name, @parent_space)
          end
        end
      end
    end
  end
end
