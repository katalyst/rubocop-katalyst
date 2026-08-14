# frozen_string_literal: true

module RuboCop
  module Cop
    module Koi
      # Koi admin tables should link to each record exactly once, from the
      # column that identifies the record, and that link should render as a
      # row heading (`th`) for accessibility.
      #
      # When a table renders a single record link, mark it as the row heading
      # with `heading: true` (autocorrectable). When a table renders more
      # than one record link, the extra columns should use `text` instead;
      # `heading: false` documents an intentional exception. Links that
      # override `url:` are not record links, so they are ignored, as are
      # links that forward options (`**options`).
      #
      # erb_lint feeds RuboCop one ERB tag at a time, so the fragment being
      # inspected is not enough context to count links. When linting a view,
      # this cop reads the whole file from disk and counts record links
      # across all of its ERB tags. Outside a view file it counts links in
      # the current source. Counting is per file, so a view that renders two
      # tables is treated as one.
      #
      # This cop only takes effect through erb_lint: plain `rubocop` does not
      # inspect `.erb` files, and the `Include` configuration restricts it to
      # Koi admin views.
      #
      # @example
      #   # bad
      #   row.link(:name)
      #
      #   # good
      #   row.link(:name, heading: true)
      #
      #   # good - not a record link
      #   row.link(:name, url: :edit_admin_page_path)
      #
      #   # good - intentional extra link
      #   row.link(:name, heading: true)
      #   row.link(:homepage, heading: false)
      class TableLinkHeading < Base
        extend AutoCorrector

        MSG_HEADING = "The record link should be the row heading; add `heading: true`."
        MSG_EXTRA   = "Tables should link to the record once, from the column that identifies it. " \
                      "Use `text` instead, or `heading: false` to keep an intentional extra link."

        RESTRICT_ON_SEND = %i[link].freeze

        # How erb_lint trims trailing block expressions from ERB tags, copied
        # from Rails: action_view/template/handlers/erb/erubi.rb
        BLOCK_EXPR = /\s*((\s+|\))do|\{)(\s*\|[^|]*\|)?\s*\Z/

        ERB_TAG = /<%(?:(?!%>).)*%>/m

        # @!method row_link?(node)
        def_node_matcher :row_link?, <<~PATTERN
          (send {(send nil? :row) (lvar :row)} :link _ ...)
        PATTERN

        def on_new_investigation
          super
          @record_link_count = nil
        end

        def on_send(node)
          return unless row_link?(node)

          options = options(node)
          return if options && explicit_options?(options)

          anchor = node.arguments.reject(&:block_pass_type?).last
          return unless anchor

          if record_link_count > 1
            add_offense(node, message: MSG_EXTRA)
          else
            add_offense(node, message: MSG_HEADING) do |corrector|
              corrector.insert_after(anchor, ", heading: true")
            end
          end
        end

        private

        def options(node)
          arg = node.arguments.reject(&:block_pass_type?).last
          arg if arg&.hash_type?
        end

        # Skip if heading is already set, options are forwarded (splat), or
        # the link is not a record link (url override).
        def explicit_options?(options)
          options.children.any?(&:kwsplat_type?) ||
            options.pairs.any? { |pair| pair.key.sym_type? && %i[heading url].include?(pair.key.value) }
        end

        # A `row.link` renders a record link unless it overrides `url:`.
        # Links that forward options are indeterminate, so they don't count.
        def record_link?(node)
          return false unless row_link?(node)

          options = options(node)
          return true if options.nil?

          options.children.none?(&:kwsplat_type?) &&
            options.pairs.none? { |pair| pair.key.sym_type? && pair.key.value == :url }
        end

        def record_link_count
          @record_link_count ||= if (source = view_source)
                                   count_record_links_in_erb(source)
                                 else
                                   count_record_links(processed_source.ast)
                                 end
        end

        def view_source
          path = processed_source.file_path

          File.read(path) if path&.end_with?(".erb") && File.file?(path)
        end

        def count_record_links_in_erb(source)
          source.scan(ERB_TAG).sum do |tag|
            next 0 if tag.start_with?("<%#")

            code = tag.sub(/\A<%[=-]*/, "").sub(/-?%>\z/, "").sub(BLOCK_EXPR, "")
            count_record_links(parse_fragment(code))
          end
        end

        def count_record_links(ast)
          return 0 if ast.nil?

          ast.each_node(:send).count { |node| record_link?(node) }
        end

        def parse_fragment(code)
          ProcessedSource.new(code, processed_source.ruby_version).ast
        end
      end
    end
  end
end
