# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/role'

module Gzr
  module Commands
    class Role
      class UserRm < Gzr::Command
        include Gzr::Role
        def initialize(role_id,users,options)
          super()
          @role_id = role_id
          @users = users.collect { |u| u.to_i }
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          
          with_session do
            users = query_role_users(@role_id, 'id').collect { |u| u.id }
            users -= @users
            set_role_users(@role_id,users.uniq)
          end
        end
      end
    end
  end
end
