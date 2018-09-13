# frozen_string_literal: true

require_relative 'subcommandbase'

module Gzr
  module Commands
    class Query < SubCommandBase

      namespace :query

      desc 'runquery QUERY_DEF', 'Run query_id, query_slug, or json_query_desc'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :file, type: :string,
                           desc: 'Filename for saved data'
      method_option :format, type: :string, default: 'json',
                           desc: 'One of json,json_detail,csv,txt,html,md,xlsx,sql,png,jpg'
      def runquery(query_def)
        if options[:help]
          invoke :help, ['runquery']
        else
          require_relative 'query/runquery'
          Gzr::Commands::Query::RunQuery.new(query_def,options).execute
        end
      end
    end
  end
end
