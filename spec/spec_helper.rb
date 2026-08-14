# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"

require "rubocop/katalyst"

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense

  config.disable_monkey_patching!
  config.order = :random

  Kernel.srand config.seed
end
