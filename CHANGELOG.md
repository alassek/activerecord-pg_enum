# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
