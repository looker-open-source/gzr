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

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gzr/version"

Gem::Specification.new do |spec|
  spec.name          = "gazer"
  spec.license       = "MIT"
  spec.version       = Gzr::VERSION
  spec.authors       = ["Mike DeAngelo"]
  spec.email         = ["drstrangelove@google.com"]

  spec.summary       = %q{Command line tool to manage the content of a Looker instance.}
  spec.description   = %q{This tool will help manage the content of a Looker instance.}
  spec.homepage      = "https://github.com/looker-open-source/gzr"

  spec.required_ruby_version = '>= 2.3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-reader", "~> 0.9.0"
  spec.add_dependency "tty-table", "~> 0.12.0"
  spec.add_dependency "tty-tree", "~> 0.4.0"
  spec.add_dependency "pastel", "~> 0.8.0"
  spec.add_runtime_dependency 'thor', '~> 1.1', '>= 1.1.0'
  spec.add_dependency 'netrc', "~> 0.11.0"
  spec.add_runtime_dependency 'rubyzip', '~> 1.3', '>= 1.3.0'
  spec.add_dependency 'faraday', "~> 2.7.8"
  spec.add_dependency 'faraday-multipart', '~> 1.0'
  spec.add_dependency 'looker-sdk', "~> 0.1.6"
  spec.add_runtime_dependency 'net-http-persistent', '~> 4.0', '>= 4.0.1'

  spec.add_development_dependency 'bundler', '~> 2.2', '>= 2.2.10'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec_junit_formatter"
end
