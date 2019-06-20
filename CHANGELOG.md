# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
