lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rubocop/katalyst/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = "rubocop-katalyst"
  spec.version       = Rubocop::Katalyst::VERSION
  spec.authors       = ["Matt Redmond"]
  spec.email         = ["matt@katalyst.com.au"]

  spec.summary       = "Katalyst defaults for Rubocop"
  spec.description   = "Default settings for Rubocop in Katalyst projects"
  spec.homepage      = "https://github.com/katalyst/rubocop-katalyst"
  spec.license       = "MIT"

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "https://github.com/katalyst/rubocop-katalyst/tree/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubocop"
  spec.add_dependency "rubocop-performance"
  spec.add_dependency "rubocop-rails"
  spec.add_dependency "rubocop-rspec"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
