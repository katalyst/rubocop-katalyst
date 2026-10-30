# frozen_string_literal: true

require "rake"
require "rake/tasklib"
require "json"

module RuboCop
  module Katalyst
    # Provides a custom rake task.
    #
    # require 'rubocop/katalyst/prettier_task'
    # RuboCop::Katalyst::PrettierTask.new
    class PrettierTask < ::Rake::TaskLib
      attr_accessor :verbose

      def initialize(verbose: true)
        super()

        @verbose = verbose

        desc "Run Prettier" unless ::Rake.application.last_description
        task(prettier: "prettier:lint")

        task(lint: :prettier)
        task(autocorrect: "prettier:autocorrect")

        setup_subtasks
      end

      private

      def yarn(*options)
        sh("yarn", *options)
      end

      def installed?
        File.exist?(config)
      end

      def config
        File.join(root, ".prettierrc.json")
      end

      # True when the nearest package.json (walking up from the working
      # directory) already declares prettier. `yarn add` would rewrite that
      # file and its lockfile, which leaves a dirty tree when a gem builds its
      # dummy app in CI before running `rake release`.
      def prettier_declared?
        package_json = Pathname.new(root).ascend.map { |dir| dir.join("package.json") }.find(&:exist?)
        return false unless package_json

        json = JSON.parse(package_json.read)
        %w[dependencies devDependencies].any? { |key| json[key].is_a?(Hash) && json[key].key?("prettier") }
      end

      def install_prettier
        yarn("add", "--dev", "prettier") unless prettier_declared?
        File.write(config, <<~JSON)
          {}
        JSON
        yarn("install")
      end

      def setup_subtasks
        namespace :prettier do
          desc "Install npm packages with yarn"
          task install: :environment do
            install_prettier unless installed?
          end

          desc "Lint JS/SCSS files using prettier"
          task lint: :install do
            yarn("run", "prettier", "--check", *paths)
          end

          desc "Autocorrect JS/SCSS files using prettier"
          task autocorrect: :install do
            yarn("run", "prettier", "--write", *paths)
          end
        end
      end

      def paths
        %w[
          app/assets/config
          app/assets/javascripts
          app/assets/stylesheets
          app/javascript
          app/packs
        ].map { |path| File.join(root, path) }
          .select { |path| File.exist?(path) }
      end

      def root
        @root ||= Dir.pwd
      end
    end
  end
end
