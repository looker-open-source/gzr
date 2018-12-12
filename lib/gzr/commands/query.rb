# The MIT License (MIT)

# Copyright (c) 2018 Mike DeAngelo Looker Data Sciences, Inc.

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
