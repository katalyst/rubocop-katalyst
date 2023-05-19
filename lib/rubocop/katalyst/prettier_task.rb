# frozen_string_literal: true

require "rake"
require "rake/tasklib"

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
        config.exist?
      end

      def config
        ::Rails.application.root.join(".prettierrc.json")
      end

      def install_prettier
        yarn("add", "--dev", "prettier")
        config.open("w") do |f|
          f.write <<~JSON
            {}
          JSON
        end
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
          app/assets/javascripts
          app/assets/stylesheets
        ]
      end
    end
  end
end
