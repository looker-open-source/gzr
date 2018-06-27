# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/role'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class Role
      class Cat < Gzr::Command
        include Gzr::Role
        include Gzr::FileHelper
        def initialize(role_id,options)
          super()
          @role_id = role_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_role(@role_id)
            write_file(@options[:dir] ? "Role_#{data.id}_#{data.name}.json" : nil, @options[:dir], nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
