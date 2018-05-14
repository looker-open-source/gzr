# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/look'
require_relative '../../modules/user'
require_relative '../../modules/filehelper'

module Lkr
  module Commands
    class Look
      class Import < Lkr::Command
        include Lkr::Look
        include Lkr::User
        include Lkr::FileHelper
        def initialize(file, dest_space_id, options)
          super()
          @file = file
          @dest_space_id = dest_space_id
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning("options: #{@options.inspect}") if @options[:debug]
          with_session do
            read_file(@file) do |data|
              new_query = create_fetch_query(data[:query])
              upsert_look(query_me("id").id,new_query.id,@dest_space_id,data)
            end
          end
        end
      end
    end
  end
end
