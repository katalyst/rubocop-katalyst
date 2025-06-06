# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name    = "rubocop-katalyst"
  s.version = "2.2.1"
  s.authors = ["Katalyst Interactive"]
  s.email   = ["developers@katalyst.com.au"]

  s.summary               = "Code standards for Katalyst"
  s.homepage              = "https://github.com/katalyst/rubocop-katalyst"
  s.license               = "MIT"
  s.required_ruby_version = ">= 3.3"

  s.files         = Dir["{config,lib}/**/*",
                        "CHANGELOG.md",
                        "LICENSE.txt",
                        "README.md",
                        ".erb-lint.yml",
                        "package.json"]
  s.require_paths = ["lib"]

  s.metadata["allowed_push_host"] = "https://rubygems.org"
  s.metadata["rubygems_mfa_required"] = "true"

  s.metadata["default_lint_roller_plugin"] = "RuboCop::Katalyst::Plugin"

  s.add_dependency "lint_roller"

  s.add_dependency "rubocop"
  s.add_dependency "rubocop-capybara"
  s.add_dependency "rubocop-factory_bot"
  s.add_dependency "rubocop-performance"
  s.add_dependency "rubocop-rails"
  s.add_dependency "rubocop-rake"
  s.add_dependency "rubocop-rspec"
  s.add_dependency "rubocop-rspec_rails"
end
