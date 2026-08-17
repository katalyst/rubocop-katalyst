# frozen_string_literal: true

module RuboCop
  module Cop
    module Koi
      # Content items are duplicated for copy-on-write editing, and owned
      # detail records must be duplicated with them. katalyst-content
      # provides `duplicates_association` for this; without it the duplicate
      # silently loses the detail record when the item is next edited.
      #
      # An association is considered an owned detail when it declares
      # `dependent: :destroy` and is autosaved, either explicitly with
      # `autosave: true` or implicitly via `accepts_nested_attributes_for`.
      #
      # The cop only applies where `duplicates_association` is available:
      # classes that extend one of the configured `BaseClasses`
      # (`Katalyst::Content::Item` by default), include
      # `Katalyst::Content::DuplicatesAssociations`, or already call
      # `duplicates_association`.
      #
      # @example
      #   # bad
      #   class Embed < Katalyst::Content::Item
      #     has_one :embed_detail, autosave: true, dependent: :destroy
      #   end
      #
      #   # good
      #   class Embed < Katalyst::Content::Item
      #     has_one :embed_detail, autosave: true, dependent: :destroy
      #     duplicates_association :embed_detail
      #   end
      class DuplicatesAssociation < Base
        extend AutoCorrector

        MSG = "Owned associations are duplicated with the item; " \
              "declare `duplicates_association :%<name>s`."

        RESTRICT_ON_SEND = %i[has_one has_many].freeze

        BASE_CLASSES_DEFAULT = ["Katalyst::Content::Item"].freeze

        # @!method association(node)
        def_node_matcher :association, <<~PATTERN
          (send nil? {:has_one :has_many} (sym $_) $(hash ...))
        PATTERN

        # @!method duplicates_association_names(node)
        def_node_search :duplicates_association_names, <<~PATTERN
          (send nil? :duplicates_association (sym $_)+)
        PATTERN

        # @!method includes_concern?(node)
        def_node_search :includes_concern?, <<~PATTERN
          (send nil? :include (const _ :DuplicatesAssociations))
        PATTERN

        # @!method nested_attributes(node)
        def_node_search :nested_attributes, <<~PATTERN
          $(send nil? :accepts_nested_attributes_for (sym $_) ...)
        PATTERN

        def on_send(node)
          association(node) do |name, options|
            klass = node.each_ancestor(:class).first
            return unless klass
            return unless owned?(klass, name, options)
            return unless duplication_available?(klass)
            return if declared?(klass, name)

            add_offense(node, message: format(MSG, name:)) do |corrector|
              anchor = nested_attributes_node(klass, name) || node
              corrector.insert_after(anchor, "\n#{' ' * anchor.loc.column}duplicates_association :#{name}")
            end
          end
        end

        private

        def owned?(klass, name, options)
          option?(options, :dependent, :destroy) &&
            (option?(options, :autosave, true) || nested_attributes_node(klass, name))
        end

        def option?(options, key, value)
          options.pairs.any? do |pair|
            pair.key.sym_type? && pair.key.value == key && option_value?(pair.value, value)
          end
        end

        def option_value?(node, value)
          case value
          when true then node.true_type?
          when Symbol then node.sym_type? && node.value == value
          end
        end

        def duplication_available?(klass)
          base_classes.include?(klass.parent_class&.source) ||
            includes_concern?(klass) ||
            duplicates_association_names(klass).any?
        end

        def base_classes
          cop_config.fetch("BaseClasses", BASE_CLASSES_DEFAULT)
        end

        def declared?(klass, name)
          duplicates_association_names(klass).any? { |names| names.include?(name) }
        end

        def nested_attributes_node(klass, name)
          nested_attributes(klass).find { |_node, sym| sym == name }&.first
        end
      end
    end
  end
end
