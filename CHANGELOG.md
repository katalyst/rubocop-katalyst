## [3.2.0] - 2026-08-17

- Add Koi/DuplicatesAssociation identifying Katalyst::Content items that
  have associations but don't use the library-provided `duplicates_association`
  helper.

## [3.1.0] - 2026-08-14

- Add Koi department for custom cops specific to katalyst-koi projects,
  configured in `config/rubocop-koi.yml` and applied to admin views via erb_lint
- Add Koi/TableLinkHeading cop: tables in admin index/archived views and row
  partials should link to the record once, from the column that identifies
  it. A single record link must be marked `heading: true` (autocorrectable);
  additional links should use `text`, or `heading: false` when intentional
- Run tests and linting in CI via `bin/ci`
- Remove prettier/yarn from this repository and stop shipping `package.json`
  in the gem — nothing consumed it, and downstream `PrettierTask` installs
  prettier in the host project itself

## [3.0.0] - 2026-05-21

- Update Ruby minimum version and syntax to 4.0
- Enable ForceEqualSignAlignment

## [2.0.0] - 2024-06-12

- Update ruby syntax to 3.3
- Update rubocop-rails to 3.0
- See rubocop-rails upgrade notes for more details

## [1.1.0] - 2023-05-19

- Add erb_lint rake task and config (optional dependency)
- Add prettier rake task and config (assumes yarn)

## [1.0.5] - 2023-03-16

- Add extra prefixes for spec contexts
- Allow repeated examples in policy specs

## [1.0.2] - 2022-09-02

- ignore multiple expectations in features and system specs

## [1.0.1] - 2022-08-30

- disabling Style/CollectionMethods as it causes an error with autocorrection

## [1.0.0] - 2022-08-29

- Bump dependency versions
- Compatibility with rubocop 1.35.1
- Relax example length rule for feature and system specs

## [0.1.1] - 2021-11-15

- Bump dependency versions
- Ensure compiled gem is excluded from source control

## [0.1.0] - 2021-10-20

- Initial release
- Disable new cops by default
- Enforce styles within the project
