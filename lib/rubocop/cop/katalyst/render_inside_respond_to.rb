# frozen_string_literal: true

module RuboCop
  module Cop
    module Katalyst
      # Controllers should render templates inside `respond_to`, listing the
      # formats that have a template.
      #
      # An action without a `render` call renders implicitly, and Rails answers
      # a format it has no template for with 406 Not Acceptable. An explicit
      # `render` skips that check: a request for markdown or JSON looks up a
      # template that does not exist and raises ActionView::MissingTemplate, a
      # 500. Inside `respond_to`, an unlisted format raises
      # ActionController::UnknownFormat instead, which Rails answers with 406.
      #
      # Renders that bring their own body (`json:`, `plain:`, `turbo_stream:`
      # and so on), renders that force a format with `formats:`, and renders of
      # a component instance never look up a template by the request's format,
      # so they are not registered.
      #
      # The cop does not check which formats are listed. Use
      # `format.any(:html, :turbo_stream)` when the action has a turbo stream
      # template. It does not autocorrect for the same reason.
      #
      # @example
      #   # bad
      #   def show
      #     render locals: { venue: }
      #   end
      #
      #   # good
      #   def show
      #     respond_to do |format|
      #       format.html { render locals: { venue: } }
      #     end
      #   end
      #
      #   # good
      #   def update
      #     respond_to do |format|
      #       format.any(:html, :turbo_stream) { render locals: { collection: } }
      #     end
      #   end
      #
      #   # good
      #   render json: venue
      class RenderInsideRespondTo < Base
        MSG = "Render templates inside `respond_to` so unsupported formats answer 406, not a 500."

        RESTRICT_ON_SEND = %i[render].freeze

        TEMPLATELESS_KEYS = %i[body file formats html inline js json plain renderable turbo_stream xml].to_set.freeze

        # @!method component_instance?(node)
        def_node_matcher :component_instance?, <<~PATTERN
          (send const :new ...)
        PATTERN

        def on_send(node)
          return unless node.receiver.nil?
          return if inside_respond_to?(node)
          return if renders_without_template?(node)

          add_offense(node)
        end

        private

        def inside_respond_to?(node)
          node.each_ancestor(:any_block).any? do |block|
            block.send_node.receiver.nil? && block.method?(:respond_to)
          end
        end

        def renders_without_template?(node)
          return true if node.arguments? && component_instance?(node.first_argument)

          node.arguments.select(&:hash_type?).flat_map(&:keys).any? do |key|
            key.sym_type? && TEMPLATELESS_KEYS.include?(key.value)
          end
        end
      end
    end
  end
end
