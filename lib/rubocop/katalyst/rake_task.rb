# frozen_string_literal: true

require "rubocop/rake_task"

module RuboCop
  module Katalyst
    # Provides a custom rake task.
    #
    # require "rubocop/katalyst/rake_task"
    # RuboCop::Katalyst::RakeTask.new
    class RakeTask < ::RuboCop::RakeTask
      attr_accessor :verbose

      def initialize(name = :rubocop, *, &)
        super

        task(lint: :rubocop)
        task(autocorrect: "rubocop:autocorrect")
      end
    end
  end
end
