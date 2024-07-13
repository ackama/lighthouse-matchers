# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2024-07-13
### Changed
- Raise an explict error when the audit category is not found ([#56](https://github.com/ackama/lighthouse-matchers/pull/56))
- Print run warnings from Lighthouse ([#55](https://github.com/ackama/lighthouse-matchers/pull/55))

## [1.1.0] - 2023-08-27
### Changed
- Only run audits for categories that are requested to improve performance ([#28](https://github.com/ackama/lighthouse-matchers/pull/28))
- Include measured score in failure message ([#26](https://github.com/ackama/lighthouse-matchers/pull/26))

## [1.0.3] - 2019-08-27
### Added
- **chrome_flags** option to allow the Chrome launch behaviour of the `lighthouse` command. (#8)

## [1.0.2] - 2019-08-16
### Changed
- Refactored auditing into a service object (@CaraHill)

## [1.0.1] - 2019-05-24
### Changed
- Apply bug fixes based on integration with a Ruby on Rails project

## [1.0.0] - 2019-05-24
### Added
- Initial version release with minimal viable matcher
