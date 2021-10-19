# Rubocop::Katalyst

[Katalyst's](https://katalyst.com.au) style guide for Ruby and Rails, in gem form. Katalyst does not at present have any custom cops; this is simply a repository for our configuration of the standard cops with Rails, Rake, Performance and RSpec extensions.

Cops are broken down by department; a file corresponding to each department can be found in the `config` directory, as well as the `default.yml` file which contains any global configuration and loads the cops. The `.rubocop.yml` file contains the configuration for this particular project as a guide for use in non-Rails environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-katalyst', require: false
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rubocop-katalyst

## Usage

Add the following to your `.rubocop.yml` file:

```yml
require:
  - rubocop-katalyst
```

That's it. You're all set to use Katalyst's base code styles. Override what you need in your `.rubocop.yml` file as the project demands.

The gem is designed for use with Rails, so if you're using this in a non-Rails environment, you can disable the Rails cops in your configuration file with:

```yml
Rails:
  Enabled: false
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rubocop-katalyst. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/katalyst/rubocop-katalyst/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rubocop::Katalyst project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/katalyst/rubocop-katalyst/blob/main/CODE_OF_CONDUCT.md).
