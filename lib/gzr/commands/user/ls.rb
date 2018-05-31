# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/user'
require 'tty-table'

module Gzr
  module Commands
    class User
      class Ls < Gzr::Command
        include Gzr::User
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            f = @options[:fields]
            f += ',credentials_email,credentials_totp,credentials_google,credentials_saml,credentials_oidc' if @options[:"last-login"]
            data = query_all_users(f, "id")
            begin
              say_ok "No users found"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            fields = field_names(@options[:fields])
            fields.unshift 'last_login' if @options[:"last-login"]
            table_hash[:header] = fields unless @options[:plain]
            expressions = fields.collect { |fn| field_expression(fn) }
            table_hash[:rows] = data.map do |row|
              expressions.collect do |e|
                next(eval "row.#{e}") unless (e == 'last_login')
                [
                  row.credentials_email()&.logged_in_at(),
                  (row.credentials_totp()&.logged_in_at()),
                  (row.credentials_google()&.logged_in_at()),
                 (row.credentials_saml()&.logged_in_at()),
                  (row.credentials_oidc()&.logged_in_at())
                ].compact.max
              end
            end
            table = TTY::Table.new(table_hash)
            alignments = fields.collect do |k|
              (k =~ /id$/) ? :right : :left
            end
            begin
              if @options[:csv] then
                output.puts render_csv(table)
              else
                output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments)
              end
            end if table
          end
        end
      end
    end
  end
end
