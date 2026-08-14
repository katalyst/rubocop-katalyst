# frozen_string_literal: true

require "spec_helper"

require "tmpdir"

RSpec.describe RuboCop::Cop::Koi::TableLinkHeading, :config do
  context "with a single record link" do
    it "registers an offense when a row link has no options" do
      expect_offense(<<~RUBY)
        row.link :name
        ^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
      RUBY

      expect_correction(<<~RUBY)
        row.link :name, heading: true
      RUBY
    end

    it "registers an offense when a row link has unrelated options" do
      expect_offense(<<~RUBY)
        row.link(:name, label: "Name")
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
      RUBY

      expect_correction(<<~RUBY)
        row.link(:name, label: "Name", heading: true)
      RUBY
    end

    it "corrects before a block pass argument" do
      expect_offense(<<~RUBY)
        row.link(:status, &:status_label)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
      RUBY

      expect_correction(<<~RUBY)
        row.link(:status, heading: true, &:status_label)
      RUBY
    end

    it "registers an offense when row is a block variable" do
      expect_offense(<<~RUBY)
        table_with(collection: @people) do |row|
          row.link :name
          ^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
        end
      RUBY

      expect_correction(<<~RUBY)
        table_with(collection: @people) do |row|
          row.link :name, heading: true
        end
      RUBY
    end

    it "does not register an offense when heading is set" do
      expect_no_offenses(<<~RUBY)
        row.link(:name, heading: true)
      RUBY
    end

    it "does not register an offense when heading is explicitly disabled" do
      expect_no_offenses(<<~RUBY)
        row.link(:name, heading: false)
      RUBY
    end

    it "does not register an offense when the url is overridden" do
      expect_no_offenses(<<~RUBY)
        row.link(:name, url: :edit_admin_page_path)
      RUBY
    end

    it "does not register an offense when options are forwarded" do
      expect_no_offenses(<<~RUBY)
        row.link(:name, **options)
      RUBY
    end

    it "does not register an offense for links on other receivers" do
      expect_no_offenses(<<~RUBY)
        builder.link :name
      RUBY
    end
  end

  context "with multiple record links" do
    it "registers an offense without a correction for each unmarked link" do
      expect_offense(<<~RUBY)
        table_with(collection: @people) do |row|
          row.link :name
          ^^^^^^^^^^^^^^ Tables should link to the record once, from the column that identifies it. Use `text` instead, or `heading: false` to keep an intentional extra link.
          row.link :email
          ^^^^^^^^^^^^^^^ Tables should link to the record once, from the column that identifies it. Use `text` instead, or `heading: false` to keep an intentional extra link.
        end
      RUBY

      expect_no_corrections
    end

    it "only flags links without an explicit heading option" do
      expect_offense(<<~RUBY)
        table_with(collection: @people) do |row|
          row.link :name, heading: true
          row.link :email
          ^^^^^^^^^^^^^^^ Tables should link to the record once, from the column that identifies it. Use `text` instead, or `heading: false` to keep an intentional extra link.
        end
      RUBY

      expect_no_corrections
    end
  end

  context "when linting a view file" do
    # erb_lint lints one ERB tag at a time, so the cop reads the view from
    # disk to count record links. These specs lint a single fragment (as
    # erb_lint would) against a view file written to disk.
    let(:dir) { Dir.mktmpdir }

    after { FileUtils.remove_entry(dir) }

    def view_file(content)
      # The path must match the cop's Include patterns from config/rubocop-koi.yml
      path = File.join(dir, "app/views/admin/people/index.html.erb")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
      path
    end

    it "counts record links across the whole view" do
      path = view_file(<<~ERB)
        <%= table_with(collection: @people) do |row| %>
          <% row.link :name %>
          <% row.link :email %>
        <% end %>
      ERB

      expect_offense(<<~RUBY, path)
        row.link :name
        ^^^^^^^^^^^^^^ Tables should link to the record once, from the column that identifies it. Use `text` instead, or `heading: false` to keep an intentional extra link.
      RUBY

      expect_no_corrections
    end

    it "does not count url overrides as record links" do
      path = view_file(<<~ERB)
        <%= table_with(collection: @people) do |row| %>
          <% row.link :name %>
          <% row.link :edit, url: :edit_admin_person_path %>
        <% end %>
      ERB

      expect_offense(<<~RUBY, path)
        row.link :name
        ^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
      RUBY

      expect_correction(<<~RUBY)
        row.link :name, heading: true
      RUBY
    end

    it "counts links that already declare a heading option" do
      path = view_file(<<~ERB)
        <%= table_with(collection: @people) do |row| %>
          <% row.link :name, heading: false %>
          <% row.link :email %>
        <% end %>
      ERB

      expect_offense(<<~RUBY, path)
        row.link :email
        ^^^^^^^^^^^^^^^ Tables should link to the record once, from the column that identifies it. Use `text` instead, or `heading: false` to keep an intentional extra link.
      RUBY

      expect_no_corrections
    end

    it "does not count links in ERB comments" do
      path = view_file(<<~ERB)
        <%= table_with(collection: @people) do |row| %>
          <%# row.link :email %>
          <% row.link :name %>
        <% end %>
      ERB

      expect_offense(<<~RUBY, path)
        row.link :name
        ^^^^^^^^^^^^^^ The record link should be the row heading; add `heading: true`.
      RUBY

      expect_correction(<<~RUBY)
        row.link :name, heading: true
      RUBY
    end
  end
end
