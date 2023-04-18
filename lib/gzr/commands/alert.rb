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
  module Commands
    class Alert < Thor

      namespace :alert

      desc 'ls', 'list alerts'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :fields, type: :string, default: 'id,field(title,name),comparison_type,threshold,cron,custom_title,dashboard_element_id,description',
                           desc: 'Fields to display'
      method_option :disabled, type: :boolean, default: nil,
                           desc: 'return disabled alerts'
      method_option :all, type: :boolean, default: nil,
                           desc: 'return alerts from all users (must be admin)'
      method_option :plain, type: :boolean, default: false,
                           desc: 'print without any extra formatting'
      method_option :csv, type: :boolean, default: false,
                           desc: 'output in csv format per RFC4180'
      def ls(*)
        if options[:help]
          invoke :help, ['ls']
        else
          require_relative 'alert/ls'
          Gzr::Commands::Alert::Ls.new(options).execute
        end
      end

      desc 'cat ALERT_ID', 'Output json information about an alert to screen or file'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :dir,  type: :string,
                           desc: 'Directory to store output file'
      def cat(alert_id)
        if options[:help]
          invoke :help, ['cat']
        else
          require_relative 'alert/cat'
          Gzr::Commands::Alert::Cat.new(alert_id,options).execute
        end
      end

      desc 'follow ALERT_ID', 'Start following the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def follow_alert(alert_id)
        if options[:help]
          invoke :help, ['follow']
        else
          require_relative 'alert/follow'
          Gzr::Commands::Alert::Follow.new(alert_id,options).execute
        end
      end

      desc 'unfollow ALERT_ID', 'Stop following the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def unfollow_alert(alert_id)
        if options[:help]
          invoke :help, ['unfollow']
        else
          require_relative 'alert/unfollow'
          Gzr::Commands::Alert::Unfollow.new(alert_id,options).execute
        end
      end

      desc 'enable ALERT_ID', 'Enable the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def enable(alert_id)
        if options[:help]
          invoke :help, ['enable']
        else
          require_relative 'alert/enable'
          Gzr::Commands::Alert::Enable.new(alert_id,options).execute
        end
      end

      desc 'disable ALERT_ID REASON', 'Disable the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def disable(alert_id,reason)
        if options[:help]
          invoke :help, ['disable']
        else
          require_relative 'alert/disable'
          Gzr::Commands::Alert::Disable.new(alert_id,reason,options).execute
        end
      end

      desc 'threshold ALERT_ID THRESHOLD', 'Change the threshold of the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def threshold(alert_id,threshold)
        if options[:help]
          invoke :help, ['threshold']
        else
          require_relative 'alert/threshold'
          Gzr::Commands::Alert::Threshold.new(alert_id,threshold,options).execute
        end
      end

      desc 'rm ALERT_ID', 'Delete the alert given by ALERT_ID'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def rm(alert_id)
        if options[:help]
          invoke :help, ['delete']
        else
          require_relative 'alert/delete'
          Gzr::Commands::Alert::Delete.new(alert_id,options).execute
        end
      end

    end
  end
end
