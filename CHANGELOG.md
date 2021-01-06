# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2021-01-05
### Fixed
- Argument bug that surfaced in Ruby 3.0

## [1.2.0] - 2020-12-09
### Added
- Support for 6.1

## [1.1.0] - 2020-01-18
### Added
- `rename_enum` command for changing the type name
- `rename_enum_value` command for changing an enum label (PostgreSQL 10+ only)

### Changed
- Refactored some code to eliminate deprecation warnings in 2.7 related to kwargs

## [1.0.5] - 2019-11-22
### Fixed
- Don't include schema name in dumped enum types to be consistent with the way tables are dumped (@TylerRick)

## [1.0.4] - 2019-11-16
### Fixed
- Dump enums declared in non-public schemas
- Fix missing `enum` method with using `change_table`

## [1.0.3] - 2019-10-13
### Fixed
- Allow enum labels to contain spaces (@AndrewSpeed)

## [1.0.2] - 2019-08-29
- Move the active_record load hook to a different place to ensure things run in the correct order

## [1.0.1] - 2019-08-16
- Update Rails 6 support to 6.0-final

## [1.0.0] - 2019-06-23
### Added
- Support for 4.1 and 4.2

### Changed
- Moved module builder to top-level `PGEnum()` method

## [0.4.0] - 2019-06-19
### Added
- `enum` method on `TableDefinition`

### Changed
- Refactored init hook to be much more flexible
- Removed `ActiveRecord::PGEnum::Helper` in favor of `ActiveRecord::PGEnum()` module builder

## [0.3.0] - 2019-03-03
- Support for 5.0 and 5.1
- Change travis config to test against oldest supported version of ruby

## [0.2.1] - 2019-02-22
- Fixed a bug in the `SchemaDumper` output

## [0.2.0] - 2018-08-18
### Changed
- Change API of `create_enum` to take two arguments instead, the name and an array of values

## [0.1.1] - 2018-08-14
- Bump Ruby requirement to 2.2.2 (for Rails 5.2) until earlier framework versions are supported.
- `enum_types` are listed in alphabetical order

## [0.1.0] - 2018-08-12
### Added
- `add_to_enum` for modifying existing types
- `ActiveRecord::Migration::CommandRecorder` is patched to make `create_enum`, and `drop_enum` reversible.

### Changed
- Ruby 2.1 is defined as the earliest supported version (for kwargs)
- `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#enum_types` returns a Hash instead of a nested Array
