# frozen_string_literal: true

require_relative "lib/rubocop/katalyst/version"

Gem::Specification.new do |spec|
  spec.name    = "rubocop-katalyst"
  spec.version = RuboCop::Katalyst::VERSION
  spec.authors = ["Matt Redmond"]
  spec.email   = ["matt.redmond@katalyst.com.au"]

  spec.summary               = "Code standards for Katalyst"
  spec.description           = "Custom RuboCop for the Katalyst styleguide"
  spec.homepage              = "https://github.com/katalyst/rubocop-katalyst"
  spec.license               = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/katalyst/rubocop-katalyst"
  spec.metadata["changelog_uri"]   = "https://github.com/katalyst/rubocop-katalyst/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|\.rubocop)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_runtime_dependency "rubocop"
  spec.add_runtime_dependency "rubocop-performance"
  spec.add_runtime_dependency "rubocop-rails"
  spec.add_runtime_dependency "rubocop-rake"
  spec.add_runtime_dependency "rubocop-rspec"
end
