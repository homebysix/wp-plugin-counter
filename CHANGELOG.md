WP Plugin Counter Change Log
============================

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]
### Fixed
- Fixed typo that resulted in bad email formatting.
### Changed
- Switched change log to [standard format](http://keepachangelog.com/).

## [1.1.3] - 2012-12-23
### Changed
- Minor changes based on shell script linter feedback.

## [1.1.2] - 2012-12-11
### Changed
- Now only prints SMS instead of sending it, if debug mode is on.
- Using `find` instead of `ls` to get current plugin count. Should be faster for sites with large numbers of plugins.

## [1.1.1] - 2014-12-04
### Added
- Added the ability to use the same log file for multiple sites.
- Added exits with error codes if settings validation fails.
- Added sendmail path validation.
### Changed
- Script now does not send alerts on first run.
- Added extra space between email printouts in debug mode.
- Changelog is now in reverse chronological order, newest at top.
- Cleaned up comments in the code.
- Changed WEBSITE_URL to WEBSITE_NAME to make clear that it doesn't have to be a URL.

## [1.1] - 2014-12-02
### Added
- Created change log (this file).
- Added support for multiple WP sites on same host.
- Added comments to settings section to explain the options.
- Added debug mode that lets you see the email that will be sent.
- Added instructions for configuring multiple email recipients.
- Verifies website and alert settings, and fails gracefully if they are set incorrectly.
### Changed
- Simplified logic to make the code easier to follow visually.

## 1.0 - 2014-11-24
### Added
- Initial public release, with basic plugin counting and alerting built in.

[unreleased]: https://github.com/homebysix/wp-plugin-counter/compare/v1.1.3...HEAD
[1.1.3]: https://github.com/homebysix/wp-plugin-counter/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/homebysix/wp-plugin-counter/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/homebysix/wp-plugin-counter/compare/v1.1...v1.1.1
[1.1]: https://github.com/homebysix/wp-plugin-counter/compare/v1.0...v1.1