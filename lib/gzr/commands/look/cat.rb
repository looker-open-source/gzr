# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/look'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Look
      class Cat < Gzr::Command
        include Gzr::Look
        include Gzr::FileHelper
        def initialize(look_id,options)
          super()
          @look_id = look_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_look(@look_id)
            write_file(@options[:dir] ? "Look_#{data.id}_#{data.title}.json" : nil, @options[:dir],nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
