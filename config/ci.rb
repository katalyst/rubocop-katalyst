# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step "Setup", "bin/setup"

  step "Style: Ruby", "bundle exec rubocop --no-server"

  step "Tests: rspec", "bundle exec rspec"
end
