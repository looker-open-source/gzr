# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/user'

module Gzr
  module Commands
    class User
      class Enable < Gzr::Command
        include Gzr::User
        def initialize(user_id,options)
          super()
          @user_id = user_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = update_user(@user_id, { :is_disabled=>false })
          end
        end
      end
    end
  end
end
