# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/space'

module Gzr
  module Commands
    class Space
      class Rm < Gzr::Command
        include Gzr::Space
        def initialize(space,options)
          super()
          @space = space
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          with_session do
            space = query_space(@space)
            children = query_space_children(@space)
            unless (space.looks.length == 0 && space.dashboards.length == 0 && children.length == 0) || @options[:force] then
              raise Gzr::Error, "Space '#{space.name}' is not empty. Space cannot be deleted unless --force is specified"
            end
            delete_space(@space)
          end
        end
      end
    end
  end
end
