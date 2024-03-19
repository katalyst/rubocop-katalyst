# frozen_string_literal: true

require "rubocop"
require "rubocop-performance"
require "rubocop-rails"
require "rubocop-rake"
require "rubocop-rspec"

require_relative "rubocop/katalyst"
require_relative "rubocop/katalyst/inject"

RuboCop::Katalyst::Inject.defaults!

require_relative "rubocop/cop/katalyst_cops"
