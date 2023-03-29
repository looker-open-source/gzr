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

require 'json'
require 'pastel'
require 'tty-reader'

require_relative '../../gzr'

module Gzr
  module Session

    def pastel
      @pastel ||= Pastel.new
    end

    def say_ok(data, output: $stdout)
      output.puts pastel.green data
    end

    def say_warning(data, output: $stdout)
      output.puts pastel.yellow data
    end

    def say_error(data, output: $stdout)
      output.puts pastel.red data
    end

    @versions = []
    @current_version = nil

    def sufficient_version?(given_version, minimum_version)
      return true unless (given_version && minimum_version)
      versions = @versions.sort
      !versions.drop_while {|v| v < minimum_version}.reverse.drop_while {|v| v > given_version}.empty?
    end


    def build_connection_hash(api_version=nil)
      conn_hash = Hash.new
      conn_hash[:api_endpoint] = "http#{@options[:ssl] ? "s" : ""}://#{@options[:host]}:#{@options[:port]}/api/#{api_version||@current_version||""}"
      if @options[:http_proxy]
        conn_hash[:connection_options] ||= {}
        conn_hash[:connection_options][:proxy] = {
          :uri => @options[:http_proxy]
        }
      end
      if @options[:ssl]
        conn_hash[:connection_options] ||= {}
        if @options[:verify_ssl] then
          conn_hash[:connection_options][:ssl] = {
            :verify => true,
            :verify_mode => (OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT)
          }
        else
          conn_hash[:connection_options][:ssl] = {
            :verify => false,
            :verify_mode => (OpenSSL::SSL::VERIFY_NONE)
          }
        end
      end
      if @options[:timeout]
        conn_hash[:connection_options] ||= {}
        conn_hash[:connection_options][:request] = {
          :timeout => @options[:timeout]
        }
      end
      conn_hash[:user_agent] = "Gazer #{Gzr::VERSION}"
      if @options[:client_id] then
        conn_hash[:client_id] = @options[:client_id]
        if @options[:client_secret] then
          conn_hash[:client_secret] = @options[:client_secret]
        else
          reader = TTY::Reader.new
          @secret ||= reader.read_line("Enter your client_secret:", echo: false)
          conn_hash[:client_secret] = @secret
        end
      else
        conn_hash[:netrc] = true
        conn_hash[:netrc_file] = "~/.netrc"
      end
      conn_hash
    end

    def login(min_api_version=nil)
      if (@options[:client_id].nil? && ENV["LOOKERSDK_CLIENT_ID"])
        @options[:client_id] = ENV["LOOKERSDK_CLIENT_ID"]
      end

      if (@options[:client_secret].nil? && ENV["LOOKERSDK_CLIENT_SECRET"])
        @options[:client_secret] = ENV["LOOKERSDK_CLIENT_SECRET"]
      end

      if (@options[:api_version].nil? && ENV["LOOKERSDK_API_VERSION"])
        @options[:api_version] = ENV["LOOKERSDK_API_VERSION"]
      end

      if (@options[:verify_ssl] && ENV["LOOKERSDK_VERIFY_SSL"])
        @options[:verify_ssl] = !(/^f(alse)?$/i =~ ENV["LOOKERSDK_VERIFY_SSL"])
      end

      if ((@options[:host] == 'localhost') && ENV["LOOKERSDK_BASE_URL"])
        base_url = ENV["LOOKERSDK_BASE_URL"]
        @options[:ssl] = !!(/^https/ =~ base_url)
        @options[:host] = /^https?:\/\/([^:\/]+)/.match(base_url)[1]
        md = /:([0-9]+)\/?$/.match(base_url)
        @options[:port] = md[1] if md
      end

      say_ok("using options #{@options.select { |k,v| k != 'client_secret' }.map { |k,v| "#{k}=>#{v}" }}") if @options[:debug]

      @secret = nil
      begin
        conn_hash = build_connection_hash

        sawyer_options = {
          :links_parser => Sawyer::LinkParsers::Simple.new,
          :serializer  => LookerSDK::Client::Serializer.new(JSON),
          :faraday => Faraday.new(conn_hash[:connection_options]) do |conn|
            if @options[:persistent]
              conn.adapter :net_http_persistent
            end
          end
        }

        endpoint = conn_hash[:api_endpoint]
        endpoint_uri = URI.parse(endpoint)
        root = endpoint.slice(0..-endpoint_uri.path.length)

        agent = Sawyer::Agent.new(root, sawyer_options) do |http|
          http.headers[:accept] = 'application/json'
          http.headers[:user_agent] = conn_hash[:user_agent]
        end

        begin
          versions_response = agent.call(:get,"/versions")
          @versions = versions_response.data.supported_versions.map {|v| v.version}
          @current_version = versions_response.data.current_version.version || "4.0"
        rescue Faraday::SSLError => e
          raise Gzr::CLI::Error, "SSL Certificate could not be verified\nDo you need the --no-verify-ssl option or the --no-ssl option?"
        rescue Faraday::ConnectionFailed => cf
          raise Gzr::CLI::Error, "Connection Failed.\nDid you specify the --no-ssl option for an ssl secured server?\nYou may need to use --port=443 in some cases as well."
        rescue LookerSDK::NotFound => nf
          say_warning "endpoint #{root}/versions was not found"
        end
      end

      say_warning "API current_version #{@current_version}" if @options[:debug]
      say_warning "API versions #{@versions}" if @options[:debug]

      raise Gzr::CLI::Error, "Operation requires API v#{min_api_version}, but user specified version #{@options[:api_version]}" unless sufficient_version?(@options[:api_version],min_api_version)

      api_version = [min_api_version, @current_version].max
      raise Gzr::CLI::Error, "Operation requires API v#{api_version}, which is not available from this host" if api_version && !@versions.any? {|v| v == api_version}
      raise Gzr::CLI::Error, "User specified API v#{@options[:api_version]}, which is not available from this host" if @options[:api_version] && !@versions.any? {|v| v == @options[:api_version]}

      conn_hash = build_connection_hash(@options[:api_version] || api_version)
      @secret = nil

      say_ok("connecting to #{conn_hash.map { |k,v| "#{k}=>#{(k == :client_secret) ? '*********' : v}" }}") if @options[:debug]

      begin
        faraday = Faraday.new(conn_hash[:connection_options]) do |conn|
          if @options[:persistent]
            conn.adapter :net_http_persistent
          end
        end
        @sdk = LookerSDK::Client.new(conn_hash.merge(faraday: faraday)) unless @sdk

        say_ok "check for connectivity: #{@sdk.alive?}" if @options[:debug]
        say_ok "verify authentication: #{@sdk.authenticated?}" if @options[:debug]
      rescue LookerSDK::Unauthorized => e
        say_error "Unauthorized - credentials are not valid"
        raise
      rescue LookerSDK::Error => e
        say_error "Unable to connect"
        say_error e.message
        say_error e.errors if e.respond_to?(:errors) && e.errors
        raise
      end
      raise Gzr::CLI::Error, "Invalid credentials" unless @sdk.authenticated?


      if @options[:su] then
        say_ok "su to user #{@options[:su]}" if @options[:debug]
        @access_token_stack.push(@sdk.access_token)
        begin
          @sdk.access_token = @sdk.login_user(@options[:su]).access_token
          say_warning "verify authentication: #{@sdk.authenticated?}" if @options[:debug]
        rescue LookerSDK::Error => e
          say_error "Unable to su to user #{@options[:su]}" 
          say_error e.message
          say_error e.errors if e.respond_to?(:errors) && e.errors
          raise
        end
      end
      @sdk
    end

    def logout_all
      pastel = Pastel.new(enabled: true)
      say_ok "logout" if @options[:debug]
      begin
        @sdk.logout
      rescue LookerSDK::Error => e
        say_error "Unable to logout"
        say_error e.message
        say_error e.errors if e.respond_to?(:errors) && e.errors
      end if @sdk
      loop do
        token = @access_token_stack.pop
        break unless token
        say_ok "logout the parent session" if @options[:debug]
        @sdk.access_token = token
        begin
          @sdk.logout
        rescue LookerSDK::Error => e
          say_error "Unable to logout"
          say_error e.message
          say_error e.errors if e.respond_to?(:errors) && e.errors
        end
      end
    end

    def with_session(min_api_version="3.0")
      return nil unless block_given?
      begin
        login(min_api_version) unless @sdk
        yield
      rescue LookerSDK::Error => e
        say_error e.errors if e.respond_to?(:errors) && e.errors
        e.backtrace.each { |b| say_error b } if @options[:debug]
        raise Gzr::CLI::Error, e.message
      ensure
        logout_all
      end
    end
  end
end
