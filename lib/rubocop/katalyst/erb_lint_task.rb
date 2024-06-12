# frozen_string_literal: true

require "rake"
require "rake/tasklib"

module RuboCop
  module Katalyst
    # Provides a custom rake task.
    #
    # require 'rubocop/katalyst/erb_lint_task'
    # RuboCop::Katalyst::ErbLintTask.new
    class ErbLintTask < ::Rake::TaskLib
      attr_accessor :verbose

      def initialize(verbose: true)
        super()

        @verbose = verbose

        desc "Run ErbLint" unless ::Rake.application.last_description
        task(erb_lint: "erb_lint:lint")

        setup_subtasks

        task(lint: :erb_lint)
        task(autocorrect: "erb_lint:autocorrect")
      end

      private

      def run_cli(verbose, *options)
        require "erb_lint/cli"

        options.unshift("--config", config.to_path, "--allow-no-files")
        cli = ERBLint::CLI.new
        puts "Running erbLint #{options.join(' ')}" if verbose
        result = cli.run(options)
        abort("ERBLint failed!") unless result
      end

      def setup_subtasks
        namespace :erb_lint do
          desc "Run erb_lint linter"
          task :lint do
            run_cli(verbose, "--lint-all")
          end

          desc "Run erb_lint autocorrect"
          task :autocorrect do
            run_cli(verbose, "--lint-all", "-a")
          end
        end
      end

      def config
        config = Pathname.new(root).join(".erb-lint.yml")
        config = default_config unless config.exist?
        config
      end

      def default_config
        Pathname.new(__dir__).join("../../../.erb-lint.yml")
      end

      def root
        @root ||= Dir.pwd
      end
    end
  end
end
