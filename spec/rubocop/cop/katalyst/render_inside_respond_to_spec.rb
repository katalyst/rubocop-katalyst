# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Katalyst::RenderInsideRespondTo, :config do
  let(:ruby_version) { 4.0 }

  it "registers an offense for a render with locals" do
    expect_offense(<<~RUBY)
      def show
        render locals: { venue: }
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
      end
    RUBY

    expect_no_corrections
  end

  it "registers an offense for a named template" do
    expect_offense(<<~RUBY)
      render "spaces/show", locals: { space: }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
    RUBY
  end

  it "registers an offense for a render without arguments" do
    expect_offense(<<~RUBY)
      render
      ^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
    RUBY
  end

  it "registers an offense for a partial" do
    expect_offense(<<~RUBY)
      render partial: service, locals: { event: }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
    RUBY
  end

  it "registers an offense for a render with a status in a private method" do
    expect_offense(<<~RUBY)
      private

      def render_failure
        render :new, locals: { form: }, status: :unprocessable_content
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
      end
    RUBY
  end

  it "registers an offense for a record, which renders its partial" do
    expect_offense(<<~RUBY)
      render @venue
      ^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
    RUBY
  end

  it "registers an offense for a render inside a block other than respond_to" do
    expect_offense(<<~RUBY)
      collection.each do |item|
        render :show, locals: { item: }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Render templates inside `respond_to` so unsupported formats answer 406, not a 500.
      end
    RUBY
  end

  it "does not register an offense inside format.html" do
    expect_no_offenses(<<~RUBY)
      respond_to do |format|
        format.html { render locals: { venue: } }
      end
    RUBY
  end

  it "does not register an offense inside format.any" do
    expect_no_offenses(<<~RUBY)
      respond_to do |format|
        format.any(:html, :turbo_stream) { render locals: { collection: } }
      end
    RUBY
  end

  it "does not register an offense inside a multi-line format block" do
    expect_no_offenses(<<~RUBY)
      respond_to do |format|
        format.html do
          render partial: service, locals: { event: }
        end
      end
    RUBY
  end

  it "does not register an offense for renders that bring their own body" do
    expect_no_offenses(<<~RUBY)
      render json: venue
      render plain: performance.to_ics
      render html: "<p>Hello</p>".html_safe
      render body: nil
      render inline: "<%= venue.title %>"
      render js: "alert()"
      render xml: venue
      render file: Rails.public_path.join("404.html")
      render renderable: registration
      render turbo_stream: turbo_stream.replace(venue)
      render(turbo_stream: form, status: :unprocessable_content)
    RUBY
  end

  it "does not register an offense for a render that forces a format" do
    expect_no_offenses(<<~RUBY)
      render :edit, formats: :html, locals: { cart:, ticket: }, status: :unprocessable_content
    RUBY
  end

  it "does not register an offense for a component instance" do
    expect_no_offenses(<<~RUBY)
      render Carts::HeaderComponent.new(cart:), layout: false
    RUBY
  end

  it "does not register an offense for render on a receiver" do
    expect_no_offenses(<<~RUBY)
      helpers.render "venues/venue", venue:
    RUBY
  end

  it "does not register an offense for an implicit render" do
    expect_no_offenses(<<~RUBY)
      def show
        @venue = Venue.find(params[:id])
      end
    RUBY
  end
end
