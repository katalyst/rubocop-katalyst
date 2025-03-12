# frozen_string_literal: true

require "rubocop"
require "rubocop-performance"
require "rubocop-rails"
require "rubocop-rake"
require "rubocop-rspec"

module RuboCop
  module Katalyst
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name:        "rubocop-katalyst",
          version:,
          homepage:    "https://github.com/katalyst/rubocop-katalyst",
          description: "Rubocop configuration for Katalyst projects.",
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type:          :path,
          config_format: :rubocop,
          value:         Pathname.new(__dir__).join("../../config/default.yml"),
        )
      end

      private

      def version
        Gem::Specification.find_by_name("rubocop-katalyst").version
      end

      def project_root
        Pathname.new(__dir__).join("../..")
      end
    end
  end
end
