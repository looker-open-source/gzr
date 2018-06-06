
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gzr/version"

Gem::Specification.new do |spec|
  spec.name          = "gazer"
  spec.license       = "MIT"
  spec.version       = Gzr::VERSION
  spec.authors       = ["Mike DeAngelo"]
  spec.email         = ["deangelo@looker.com"]

  spec.summary       = %q{Command line tool to manage the content of a Looker instance.}
  spec.description   = %q{Command line tool to manage the content of a Looker instance.}
  spec.homepage      = "https://github.com/deangelo-llooker/gzr"

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

  spec.add_dependency "tty-reader", "~> 0.3.0"
  spec.add_dependency "tty-table", "~> 0.10.0"
  spec.add_dependency "tty-tree", "~> 0.1.0"
  spec.add_dependency "pastel", "~> 0.7.2"
  spec.add_dependency "thor", "~> 0.20.0"
  spec.add_dependency 'netrc', "~> 0.11.0"
  spec.add_dependency 'looker-sdk-fork', "~> 0.0.6"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "tty", "~> 0.8"
end
