# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [UNRELEASE]
### Breaking change
  - if `--drive-key` option is used, arguments CSV files will be ignored
### Change
  - output_path is set inside runner instead of platform classes.
### Added
  - multiple CSV can now be exported, they will be exported under `outputs/<filename>/...`
  - -e|-export_all_sheets option fetches and exports all sheets from a spreadsheet

## [3.6.0] - 2020-06-23
### Added
  - add documentation for service account usage by [@sjcqs](https://github.com/sjcqs)
  - add compatibility with activesupport 6 by [@Hugo-Hache](https://github.com/Hugo-Hache)

### Changed

### Fixed

## [3.5.0] - 2020-05-12
### Added
  - add support for private spreadsheet using google service acccount by [@sjcqs](https://github.com/sjcqs). Fixes [#31](https://github.com/applidium/ad_localize/issues/31)
  - add makefile for easier testing by [@felginep](https://github.com/felginep)

### Changed
  - improve error message to have useful information in case of google spreadsheet use by [@felginep](https://github.com/felginep). Fixes [#27](https://github.com/applidium/ad_localize/issues/27)
  - platform folder is no longer generated when there is only one platform selected. The files are directly generated in the output path. By [@felginep](https://github.com/felginep). Fixes [#29](https://github.com/applidium/ad_localize/issues/29)
  - raise error when google spreadsheet key is invalid by [@felginep](https://github.com/felginep)

### Fixed
  - auto escape strings in Localizable.strings by [@felginep](https://github.com/felginep). Fixes [#26](https://github.com/applidium/ad_localize/issues/26)
  - trim keys to prevent user error by [@felginep](https://github.com/felginep). Fixes [#16](https://github.com/applidium/ad_localize/issues/16)

## [3.4.0] - 2019-02-10
### Added
  - Rails folks, [@epaillous](https://github.com/epaillous) has improved the YAML support. You can now have multi-level wording.

## [3.3.0] - 2019-02-10
### Added
  - improve React support using keys with dots to generate nested JSON files by [@epaillous](https://github.com/epaillous)

## [3.2.0] - 2019-12-10
### Added
  - Add tests to compare reference exports by [@felginep](https://github.com/felginep)
  - [iOS only] Handle [adaptive strings](https://developer.apple.com/documentation/foundation/nsstring/1413104-variantfittingpresentationwidth) by [@felginep](https://github.com/felginep)

### Changed
  - Fix issue with Info.plist format by [@felginep](https://github.com/felginep)
  - Do not export plurals for android when there are no values by [@felginep](https://github.com/felginep)

## [3.1.0] - 2019-09-30
### Added
  - [iOS only] Info.plist generation support by [@felginep](https://github.com/felginep)

### Changed
  - No more warning log for empty lines by [@felginep](https://github.com/felginep)

## [3.0.0] - 2019-02-19
TODO

## [2.1.0] - 2016-12-22
TODO

## [2.0.0] - 2016-07-05
TODO

## [1.1.0] - 2016-04-27
TODO

## [1.0.0] - 2016-04-25
TODO

## [0.1.0] - 2016-04-25
TODO
