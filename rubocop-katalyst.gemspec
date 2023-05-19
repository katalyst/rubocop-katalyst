# frozen_string_literal: true

require_relative "lib/rubocop/katalyst/version"

Gem::Specification.new do |spec|
  spec.name    = "rubocop-katalyst"
  spec.version = RuboCop::Katalyst::VERSION
  spec.authors = ["Katalyst Interactive"]
  spec.email   = ["developers@katalyst.com.au"]

  spec.summary               = "Code standards for Katalyst"
  spec.description           = "Custom RuboCop for the Katalyst styleguide"
  spec.homepage              = "https://github.com/katalyst/rubocop-katalyst"
  spec.license               = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["{config,lib}/**/*", "CHANGELOG.md", "LICENSE.txt", "README.md", ".erb-lint.yml", "package.json"]
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_runtime_dependency "rubocop"
  spec.add_runtime_dependency "rubocop-performance"
  spec.add_runtime_dependency "rubocop-rails"
  spec.add_runtime_dependency "rubocop-rake"
  spec.add_runtime_dependency "rubocop-rspec"
end
