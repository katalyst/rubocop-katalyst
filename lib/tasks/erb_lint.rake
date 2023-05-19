# frozen_string_literal: true

begin
  require "erb_lint"
rescue LoadError
  return
end

def erb_lint_config
  local = Rails.application.root.join(".erb-lint.yml")
  if local.exist?
    local.to_path
  else
    Pathname.new(__dir__).join("../../.erb-lint.yml").to_path
  end
end

namespace :erb_lint do
  desc "Require erb_lint"
  task :require do
    require "erb_lint/cli"
  rescue LoadError
    nil
  end

  desc "Run erb_lint linter"
  task lint: :require do
    ERBLint::CLI.new.run(["--config", erb_lint_config, "--lint-all"])
  end

  desc "Run erb_lint autocorrect"
  task autocorrect: :require do
    ERBLint::CLI.new.run(["--config", erb_lint_config, "--lint-all", "-a"])
  end
end

desc "Run erb_lint linter"
task erb_lint: "erb_lint:lint"
