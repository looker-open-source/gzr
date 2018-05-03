# frozen_string_literal: true

require_relative '../../command'
require 'zlib'

module Lkr
  module Commands
    class Space
      class Cat < Lkr::Command
        def initialize(options)
          super()
          @options = options
        end

        def execute(*args, input: $stdin, output: $stdout)
          say_warning("args: #{args.inspect}") if @options.debug
          say_warning("options: #{@options.inspect}") if @options.debug
          begin
            login
            data = query_space(args[0])
            write_file(@options.dir ? "Space_#{data.id}_#{data.name}.json" : nil, @options[:dir]) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          ensure
            logout_all
          end
        end
      end
    end
  end
end
