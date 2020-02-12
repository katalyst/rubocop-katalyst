# frozen_string_literal: true

require "pathname"
require "yaml"

require "rubocop"
require "rubocop-performance"
require "rubocop-rails"
require "rubocop-rspec"

require_relative "rubocop/katalyst"
require_relative "rubocop/katalyst/version"

RuboCop::Katalyst::Inject.defaults!
