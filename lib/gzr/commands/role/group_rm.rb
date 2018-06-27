# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/role'

module Gzr
  module Commands
    class Role
      class GroupRm < Gzr::Command
        include Gzr::Role
        def initialize(role_id,groups,options)
          super()
          @role_id = role_id
          @groups = groups.collect { |g| g.to_i }
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          
          with_session do
            groups = query_role_groups(@role_id, 'id').collect { |g| g.id }
            groups -= @groups
            set_role_groups(@role_id,groups.uniq)
          end
        end
      end
    end
  end
end
