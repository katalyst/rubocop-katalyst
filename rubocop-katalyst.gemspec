# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name    = "rubocop-katalyst"
  s.version = "1.2.0"
  s.authors = ["Katalyst Interactive"]
  s.email   = ["developers@katalyst.com.au"]

  s.summary               = "Code standards for Katalyst"
  s.homepage              = "https://github.com/katalyst/rubocop-katalyst"
  s.license               = "MIT"
  s.required_ruby_version = ">= 3.2"

  s.files         = Dir["{config,lib}/**/*",
                        "CHANGELOG.md",
                        "LICENSE.txt",
                        "README.md",
                        ".erb-lint.yml",
                        "package.json"]
  s.require_paths = ["lib"]

  s.metadata["allowed_push_host"] = "https://rubygems.org"
  s.metadata["rubygems_mfa_required"] = "true"

  s.add_runtime_dependency "rubocop"
  s.add_runtime_dependency "rubocop-performance"
  s.add_runtime_dependency "rubocop-rails"
  s.add_runtime_dependency "rubocop-rake"
  s.add_runtime_dependency "rubocop-rspec"
end
