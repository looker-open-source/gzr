# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Gzr
  module Commands
    class User
      class Cat < Gzr::Command
        include Gzr::User
        include Gzr::FileHelper
        def initialize(user_id,options)
          super()
          @user_id = user_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            data = query_user(@user_id,@options[:fields])
            write_file(@options[:dir] ? "User_#{data.id}_#{data.display_name}.json" : nil, @options[:dir],nil, output) do |f|
              f.puts JSON.pretty_generate(data.to_attrs)
            end
          end
        end
      end
    end
  end
end
