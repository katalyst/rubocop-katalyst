# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Koi::TableAsset, :config do
  it "registers an offense for an attachment cell" do
    expect_offense(<<~RUBY)
      row.attachment :image
      ^^^^^^^^^^^^^^^^^^^^^ Avoid attachments in index tables; display text in the table and show the attachment on the record's page instead.
    RUBY

    expect_no_corrections
  end

  it "registers an offense for an attachment cell with options" do
    expect_offense(<<~RUBY)
      row.attachment :image, variant: :admin_thumb
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid attachments in index tables; display text in the table and show the attachment on the record's page instead.
    RUBY
  end

  it "registers an offense when row is a block variable" do
    expect_offense(<<~RUBY)
      table_with(collection: @people) do |row|
        row.attachment :image
        ^^^^^^^^^^^^^^^^^^^^^ Avoid attachments in index tables; display text in the table and show the attachment on the record's page instead.
      end
    RUBY
  end

  it "registers an offense for image_tag" do
    expect_offense(<<~RUBY)
      image_tag(record.image.variant(:thumb), width: 64)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid images in index tables; display text in the table and show the image on the record's page instead.
    RUBY
  end

  it "registers an offense for image_pack_tag" do
    expect_offense(<<~RUBY)
      image_pack_tag("media/images/icon.svg")
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid images in index tables; display text in the table and show the image on the record's page instead.
    RUBY
  end

  it "does not register an offense for text cells" do
    expect_no_offenses(<<~RUBY)
      row.text :name
    RUBY
  end

  it "does not register an offense for attachment on other receivers" do
    expect_no_offenses(<<~RUBY)
      form.attachment :image
    RUBY
  end

  it "does not register an offense for image_tag on a receiver" do
    expect_no_offenses(<<~RUBY)
      helpers.image_tag("logo.png")
    RUBY
  end
end
