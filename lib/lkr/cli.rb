# frozen_string_literal: true

require 'thor'

module Lkr
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    class_option :debug, type: :boolean, default: false, desc: 'Run in debug mode'

    class_option :host, type: :string, default: 'localhost', desc: 'Looker Host'
    class_option :port, type: :string, default: '19999', desc: 'Looker API Port'
    class_option :client_id, type: :string, desc: 'API3 Client Id'
    class_option :client_secret, type: :string, desc: 'API3 Client Secret'
    class_option :api_version, type: :string, default: '3.0', desc: 'Looker API Version'
    class_option :ssl, type: :boolean, default: true, desc: 'Use ssl to communicate with host'
    class_option :verify_ssl, type: :boolean, default: true, desc: 'Verify the SSL certificate of the host'
    class_option :force, type: :boolean, default: false, desc: 'Overwrite objects on server'


    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'lkr version'
    def version
      require_relative 'version'
      puts "v#{Lkr::VERSION}"
    end
    map %w(--version -v) => :version

    require_relative 'commands/user'
    register Lkr::Commands::User, 'user', 'user [SUBCOMMAND]', 'Command description...'

    require_relative 'commands/dashboard'
    register Lkr::Commands::Dashboard, 'dashboard', 'dashboard [SUBCOMMAND]', 'Command description...'

    require_relative 'commands/look'
    register Lkr::Commands::Look, 'look', 'look [SUBCOMMAND]', 'Command description...'

    require_relative 'commands/space'
    register Lkr::Commands::Space, 'space', 'space [SUBCOMMAND]', 'Command description...'
  end
end
