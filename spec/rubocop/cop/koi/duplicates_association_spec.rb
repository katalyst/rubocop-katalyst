# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Koi::DuplicatesAssociation, :config do
  it "registers an offense for an owned has_one without duplicates_association" do
    expect_offense(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, as: :embeddable, autosave: true, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :embed_detail`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, as: :embeddable, autosave: true, dependent: :destroy
        duplicates_association :embed_detail
      end
    RUBY
  end

  it "registers an offense for an owned has_many without duplicates_association" do
    expect_offense(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_many :embed_notes, as: :notable, autosave: true, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :embed_notes`.
      end
    RUBY
  end

  it "corrects after accepts_nested_attributes_for when present" do
    expect_offense(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, autosave: true, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :embed_detail`.
        accepts_nested_attributes_for :embed_detail, update_only: true
      end
    RUBY

    expect_correction(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, autosave: true, dependent: :destroy
        accepts_nested_attributes_for :embed_detail, update_only: true
        duplicates_association :embed_detail
      end
    RUBY
  end

  it "treats nested attributes as implicit autosave" do
    expect_offense(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :embed_detail`.
        accepts_nested_attributes_for :embed_detail, update_only: true
      end
    RUBY
  end

  it "does not register an offense when duplicates_association is declared" do
    expect_no_offenses(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, autosave: true, dependent: :destroy
        duplicates_association :embed_detail
      end
    RUBY
  end

  it "does not register an offense when declared in a multi-name call" do
    expect_no_offenses(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, autosave: true, dependent: :destroy
        has_many :embed_notes, autosave: true, dependent: :destroy
        duplicates_association :embed_detail, :embed_notes
      end
    RUBY
  end

  it "does not register an offense for associations that are not owned" do
    expect_no_offenses(<<~RUBY)
      class Embed < Katalyst::Content::Item
        has_one :embed_detail, dependent: :destroy
        has_many :taggings, dependent: :destroy
        has_one :status, autosave: true
        belongs_to :container, polymorphic: true
      end
    RUBY
  end

  it "does not register an offense outside a content item class" do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        has_one :profile, autosave: true, dependent: :destroy
      end
    RUBY
  end

  it "registers an offense when the concern is included directly" do
    expect_offense(<<~RUBY)
      class Card < ApplicationRecord
        include Katalyst::Content::DuplicatesAssociations

        has_one :card_detail, autosave: true, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :card_detail`.
      end
    RUBY
  end

  it "registers an offense when another association is already declared" do
    expect_offense(<<~RUBY)
      class Card < ApplicationRecord
        has_one :card_detail, autosave: true, dependent: :destroy
        duplicates_association :card_detail

        has_many :card_notes, autosave: true, dependent: :destroy
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :card_notes`.
      end
    RUBY
  end

  context "with configured base classes" do
    let(:cop_config) { { "BaseClasses" => ["ApplicationItem"] } }

    it "registers an offense for the configured base class" do
      expect_offense(<<~RUBY)
        class Embed < ApplicationItem
          has_one :embed_detail, autosave: true, dependent: :destroy
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Owned associations are duplicated with the item; declare `duplicates_association :embed_detail`.
        end
      RUBY
    end

    it "does not register an offense for other classes" do
      expect_no_offenses(<<~RUBY)
        class Embed < Katalyst::Content::Item
          has_one :embed_detail, autosave: true, dependent: :destroy
        end
      RUBY
    end
  end
end
