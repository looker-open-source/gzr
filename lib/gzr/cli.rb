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

require 'thor'

module Gzr
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :debug, type: :boolean, default: false, desc: 'Run in debug mode'
    class_option :host, type: :string, default: 'localhost', desc: 'Looker Host'
    class_option :port, type: :string, default: '19999', desc: 'Looker API Port'
    class_option :client_id, type: :string, desc: 'API3 Client Id'
    class_option :client_secret, type: :string, desc: 'API3 Client Secret'
    class_option :api_version, type: :string, desc: 'Looker API Version'
    class_option :ssl, type: :boolean, default: true, desc: 'Use ssl to communicate with host'
    class_option :verify_ssl, type: :boolean, default: true, desc: 'Verify the SSL certificate of the host'
    class_option :timeout, type: :numeric, default: 60, desc: 'Seconds to wait for a response from the server'
    class_option :http_proxy, type: :string, desc: 'HTTP Proxy for connecting to Looker host'
    class_option :force, type: :boolean, default: false, desc: 'Overwrite objects on server'
    class_option :su, type: :string, desc: 'After connecting, change to user_id given'
    class_option :width, type: :numeric, default: nil, desc: 'Width of rendering for tables'
    class_option :persistent, type: :boolean, default: false, desc: 'Use persistent connection to communicate with host'

    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'gzr version'
    def version
      require_relative 'version'
      puts "v#{Gzr::VERSION}"
    end
    map %w(--version -v) => :version
    map folder: :space  # Alias folder command to space

    require_relative 'commands/attribute'
    register Gzr::Commands::Attribute, 'attribute', 'attribute [SUBCOMMAND]', 'Command description...'

    require_relative 'commands/permissions'
    register Gzr::Commands::Permissions, 'permissions', 'permissions [SUBCOMMAND]', 'Command to retrieve available permissions'

    require_relative 'commands/query'
    register Gzr::Commands::Query, 'query', 'query [SUBCOMMAND]', 'Commands to retrieve and run queries'

    require_relative 'commands/role'
    register Gzr::Commands::Role, 'role', 'role [SUBCOMMAND]', 'Commands pertaining to roles'

    require_relative 'commands/plan'
    register Gzr::Commands::Plan, 'plan', 'plan [SUBCOMMAND]', 'Commands pertaining to plans'

    require_relative 'commands/group'
    register Gzr::Commands::Group, 'group', 'group [SUBCOMMAND]', 'Commands pertaining to groups'

    require_relative 'commands/model'
    register Gzr::Commands::Model, 'model', 'model [SUBCOMMAND]', 'Commands pertaining to LookML Models'

    require_relative 'commands/connection'
    register Gzr::Commands::Connection, 'connection', 'connection [SUBCOMMAND]', 'Commands pertaining to database connections and dialects'

    require_relative 'commands/user'
    register Gzr::Commands::User, 'user', 'user [SUBCOMMAND]', 'Commands pertaining to users'

    require_relative 'commands/dashboard'
    register Gzr::Commands::Dashboard, 'dashboard', 'dashboard [SUBCOMMAND]', 'Commands pertaining to dashboards'

    require_relative 'commands/look'
    register Gzr::Commands::Look, 'look', 'look [SUBCOMMAND]', 'Commands pertaining to looks'

    require_relative 'commands/space'
    register Gzr::Commands::Space, 'space', 'space [SUBCOMMAND]', 'Commands pertaining to spaces'
  end
end
