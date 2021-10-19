# frozen_string_literal: true

# The original code is from https://github.com/rubocop-hq/rubocop-rspec/blob/master/lib/rubocop/rspec/inject.rb
# See https://github.com/rubocop-hq/rubocop-rspec/blob/master/MIT-LICENSE.md
module RuboCop
  module Katalyst
    # Because RuboCop doesn't yet support plugins, we have to monkey patch in a
    # bit of our configuration.
    module Inject
      def self.defaults!
        project_root = Pathname.new(__dir__).parent.parent.parent.expand_path
        config_default = project_root.join("config", "default.yml")
        path = config_default.to_s
        hash = ConfigLoader.send(:load_file, File.new(path))
        config = RuboCop::Config.new(hash, path)
        puts "configuration from #{path}" if ConfigLoader.debug?
        config = ConfigLoader.merge_with_default(config, path)
        ConfigLoader.instance_variable_set(:@default_configuration, config)
      end
    end
  end
end
