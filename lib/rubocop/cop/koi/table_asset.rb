# frozen_string_literal: true

module RuboCop
  module Cop
    module Koi
      # Koi admin index tables should not render images or attachments.
      # Index views are for scanning and comparing records; rendering assets
      # makes rows uneven, slows the page down (variant generation and blob
      # queries per row), and rarely helps identify a record. Display text in
      # the table and show the asset on the record's page instead.
      #
      # This cop flags `row.attachment` cells and `image_tag`/`image_pack_tag`
      # helpers. It does not autocorrect; it identifies a smell for a human to
      # resolve.
      #
      # This cop only takes effect through erb_lint: plain `rubocop` does not
      # inspect `.erb` files, and the `Include` configuration restricts it to
      # Koi admin index views, so `row.attachment` in show views is fine.
      #
      # @example
      #   # bad
      #   row.attachment :image, variant: :admin_thumb
      #
      #   # bad
      #   row.cell(:image) { image_tag(record.image.variant(:thumb)) }
      #
      #   # good
      #   row.text :name
      class TableAsset < Base
        # This cop never registers a correction, but it must advertise
        # autocorrect support: erb_lint mobilizes RuboCop in autocorrect mode,
        # where non-autocorrecting cops are skipped for any fragment that an
        # autocorrecting cop has corrected (see RuboCop::Cop::Team).
        extend AutoCorrector

        MSG_ATTACHMENT = "Avoid attachments in index tables; display text in the table " \
                         "and show the attachment on the record's page instead."
        MSG_IMAGE      = "Avoid images in index tables; display text in the table " \
                         "and show the image on the record's page instead."

        RESTRICT_ON_SEND = %i[attachment image_tag image_pack_tag].freeze

        # @!method row_attachment?(node)
        def_node_matcher :row_attachment?, <<~PATTERN
          (send {(send nil? :row) (lvar :row)} :attachment ...)
        PATTERN

        # @!method image_helper?(node)
        def_node_matcher :image_helper?, <<~PATTERN
          (send nil? {:image_tag :image_pack_tag} ...)
        PATTERN

        def on_send(node)
          if row_attachment?(node)
            add_offense(node, message: MSG_ATTACHMENT)
          elsif image_helper?(node)
            add_offense(node, message: MSG_IMAGE)
          end
        end
      end
    end
  end
end
