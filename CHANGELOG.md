WP Plugin Counter Changelog
===========================

Version 1.1.3 - pending

- Minor changes based on shell script linter feedback.

Version 1.1.2 - 2012-12-11

- Now only prints SMS instead of sending it, if debug mode is on.
- Using `find` instead of `ls` to get current plugin count. Should be faster for sites with large numbers of plugins.

Version 1.1.1 - 2014-12-04

- Added the ability to use the same log file for multiple sites.
- Script now does not send alerts on first run.
- Added extra space between email printouts in debug mode.
- Changelog is now in reverse chronological order, newest at top.
- Cleaned up comments in the code.
- Changed WEBSITE_URL to WEBSITE_NAME to make clear that it doesn't have to be a URL.
- Added exits with error codes if settings validation fails.
- Added sendmail path validation.

Version 1.1 - 2014-12-02

- Created change log (this file).
- Added support for multiple WP sites on same host.
- Added comments to settings section to explain the options.
- Simplified logic to make the code easier to follow visually.
- Added debug mode that lets you see the email that will be sent.
- Added instructions for configuring multiple email recipients.
- Verifies website and alert settings, and fails gracefully if they are set incorrectly.

Version 1.0 - 2014-11-24

- Initial public release, with basic plugin counting and alerting built in.