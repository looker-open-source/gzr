# frozen_string_literal: true

require 'thor'

module Lkr
  module Commands
    class SubCommandBase < Thor
      # Workaround so that help displays the right name
      # base on this link
      # https://github.com/erikhuda/thor/issues/261#issuecomment-69327685
      def self.banner(command, namespace = nil, subcommand = false)
        "#{basename} #{subcommand_prefix} #{command.usage}"
      end

      def self.subcommand_prefix
        self.name.gsub(%r{.*::}, '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
      end
    end
  end
end
