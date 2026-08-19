# frozen_string_literal: true

require "spec_helper"

require "erb_lint/all"
require "tmpdir"

# End-to-end check that the Koi cops fire when RuboCop runs through
# erb_lint, which lints each ERB tag as an independent Ruby fragment and
# passes the view's real path through to RuboCop.
RSpec.describe "erb_lint integration" do # rubocop:disable RSpec/DescribeClass
  let(:dir) { Dir.mktmpdir }

  after { FileUtils.remove_entry(dir) }

  def lint(relative_path, content)
    path = File.join(dir, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)

    config = ERBLint::Linters::Rubocop.config_schema.new(
      config_file_path: File.expand_path("../fixtures/erb_lint/rubocop.yml", __dir__),
    )
    linter = ERBLint::Linters::Rubocop.new(ERBLint::FileLoader.new(dir), config)
    linter.run(ERBLint::ProcessedSource.new(path, content))
    linter.offenses.map(&:message).grep(%r{Koi/})
  end

  it "requires heading: true for the record link in an admin index view" do
    offenses = lint("app/views/admin/pages/index.html.erb", <<~ERB)
      <%= table_with(collection: @pages) do |row| %>
        <% row.link :name %>
      <% end %>
    ERB

    expect(offenses).to contain_exactly(a_string_matching(/add `heading: true`/))
  end

  it "guides towards a single record link when the view renders several" do
    offenses = lint("app/views/admin/pages/index.html.erb", <<~ERB)
      <%= table_with(collection: @pages) do |row| %>
        <% row.link :name %>
        <% row.link :slug %>
      <% end %>
    ERB

    expect(offenses).to contain_exactly(
      a_string_matching(/link to the record once/),
      a_string_matching(/link to the record once/),
    )
  end

  it "accepts a compliant admin index view" do
    offenses = lint("app/views/admin/pages/index.html.erb", <<~ERB)
      <%= table_with(collection: @pages) do |row| %>
        <% row.link :name, heading: true %>
        <% row.text :slug %>
      <% end %>
    ERB

    expect(offenses).to be_empty
  end

  it "flags attachments in an admin index view" do
    offenses = lint("app/views/admin/pages/index.html.erb", <<~ERB)
      <%= table_with(collection: @pages) do |row| %>
        <% row.link :name, heading: true %>
        <% row.attachment :image, variant: :admin_thumb %>
      <% end %>
    ERB

    expect(offenses).to contain_exactly(a_string_matching(/Avoid attachments in index tables/))
  end

  it "flags images in an admin table partial" do
    offenses = lint("app/views/admin/galleries/_table.html.erb", <<~ERB)
      <%= table_with(collection: items) do |row| %>
        <% row.cell :image do %>
          <%= image_tag(record.image.variant(:thumb), width: 64) %>
        <% end %>
      <% end %>
    ERB

    expect(offenses).to contain_exactly(a_string_matching(/Avoid images in index tables/))
  end

  it "does not flag attachments in an admin show view" do
    offenses = lint("app/views/admin/pages/show.html.erb", <<~ERB)
      <%= summary_table_with(model: @page) do |row| %>
        <% row.attachment :image %>
      <% end %>
    ERB

    expect(offenses).to be_empty
  end

  it "does not lint views outside the admin namespace" do
    offenses = lint("app/views/pages/index.html.erb", <<~ERB)
      <%= table_with(collection: @pages) do |row| %>
        <% row.link :name %>
      <% end %>
    ERB

    expect(offenses).to be_empty
  end
end
