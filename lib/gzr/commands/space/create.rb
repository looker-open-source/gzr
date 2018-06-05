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
          space = nil
          with_session do
            space = create_space(@name, @parent_space)
            output.puts "Created space #{space.id}" unless @options[:plain] 
            output.puts space.id if @options[:plain] 
          end
        end
      end
    end
  end
end
