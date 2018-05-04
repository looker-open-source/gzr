# frozen_string_literal: true

require_relative '../../command'

module Lkr
  module Commands
    class Look
      class Cat < Lkr::Command
        def initialize(look_id,options)
          super()
          @look_id = look_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          begin
            login
            data = query_look(@look_id)
            write_file(@options[:dir] ? "Look_#{data.id}_#{data.title}.json" : nil, @options[:dir],nil, output) do |f|
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
