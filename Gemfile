RUBY_VERSION = File.read(File.join(File.dirname(__FILE__), '.ruby-version')).split('-').last.chomp

ruby '2.3.3', engine: 'ruby', engine_version: RUBY_VERSION

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in lkr.gemspec
gemspec
gem 'looker-sdk', :git => 'git@github.com:looker/looker-sdk-ruby.git'
gem 'tty', :git => 'git@github.com:piotrmurach/tty.git'

