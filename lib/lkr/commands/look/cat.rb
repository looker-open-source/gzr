# frozen_string_literal: true

require_relative '../../command'

module Lkr
  module Commands
    class Look
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
            data = query_look(args[0])
            write_file(@options.dir ? "Look_#{data.id}_#{data.title}.json" : nil, @options[:dir]) do |f|
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
