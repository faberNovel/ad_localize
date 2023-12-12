# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- new option `--skip-value-stripping` that disable the leading and trailing whitespaces removal on wording values. The value stripping was introduced with version 6.0.0.

### Changed

- Updated dependencies
- Increase number of retries to 5 and timeout dalay to 120s when accessing Google APIs. This reduce the amount of rate limit error when using private Google spreadsheet.

## 6.1.0
### Added

- new option (iOS only) `--auto-escape-percent` that escapes % character in wording. This option should be used if the wording is intended to be used with `String(format:)`.

## 6.0.0
### Added

- Remove extra spaces before and after key/translation contents
- skip lines starting with a `#` character
- new option `-l` or `--locales` to export only a subset or locales
- Separate csv parse responsibility between key parser and csv parser
- use Rubocop to detect coding style offenses (also in github workflow)
- print warning log when a value is replaced during merge

### Changed

- parse csv in 2 steps : first analyze keys and keep them in a map, second add translations to keys
- do not store empty values during parse if `-x` option is active
- handle duplicate keys while parsing csv instead of while exporting for a platform
- BREAKING CHANGE : the way to provide service account information is no longer to set GCLOUD_CLIENT_SECRET with the content of the service account configuration. Now you need to provide the path to the configuration using the environment variable GOOGLE_APPLICATION_CREDENTIALS
- we no longer access to spreadsheet cells using GSheet v4. Now we downloaded all the relevant sheets and then we parse file contents like normal csv files. We use the exponentiel retry feature provided by google with a maximum of 3 attempts [more info here](https://github.com/googleapis/google-api-ruby-client/blob/377edf2ca4c1ef41a91de4176e5c7ad7df220007/google-apis-core/lib/google/apis/options.rb#L70). We noticed we had download error for 6 or more sheets in a spreadsheet.
- locale wording stores separately each type of wording. This allows to export each wording type concurrently if you want to
- no more plaform interactor. It has been replaced with generated file interactors. We still have an ios interactor because there are multiple files to export.
- All templated serializers now share a common parent : `TemplatedSerializer`
- Isolate the process to ensure a translation is correctly formatted for a platform in a new class type `sanitizers`. They can be tested separately.

### Removed

- no more GSpreadsheetOptions. It is handled directly in request

## [5.0.0] - 2022-07-26

### Added

- Added new option (-x) to bypass keys with empty values for iOS only in
  PR [#78](https://github.com/faberNovel/ad_localize/pull/78) by [ThomasEsterlin](https://github.com/ThomasEsterlin)

### Breaking change

- Drop support for Ruby >= 2.3, < 2.7

## [4.1.1] - 2022-04-15

### Fixed

- Fix an issue with percent export in PR [#74](https://github.com/faberNovel/ad_localize/pull/74)

## [4.1.0] - 2022-03-02

### Changed

- Do not export empty translation on Android in PR [#72](https://github.com/faberNovel/ad_localize/pull/72)

## [4.0.9] - 2021-09-05

### Fixed

- Fix error warning when spreadsheet is empty. Fix [#58](https://github.com/applidium/ad_localize/issues/58) in
  PR [#69](https://github.com/applidium/ad_localize/pull/69)
- Add warning messages when input is corrupted. Fix [#59](https://github.com/applidium/ad_localize/issues/59) in
  PR [#69](https://github.com/applidium/ad_localize/pull/69)
- Fix performance issue and add warning messages. Fix [#61](https://github.com/applidium/ad_localize/issues/61) in
  PR [#69](https://github.com/applidium/ad_localize/pull/69)
- Update deprecated `google-api-client` gem. Fix [#63](https://github.com/applidium/ad_localize/issues/63) in
  PR [#70](https://github.com/applidium/ad_localize/pull/70)

## [4.0.8] - 2021-05-25

### Fixed

- Add `NFCReaderUsageDescription` to InfoPlist keys for iOS

## [4.0.7] - 2021-05-18

### Changed

- Support Ruby 3.x

## [4.0.6] - 2020-01-25

### Fixed

- Fix google spreadsheet sheet id comparison with sheet_ids option value

## [4.0.5] - 2020-11-12

### Fixed

- Fix csv file type check (also add compatibility with macOS Big Sur)

## [4.0.4] - 2020-11-09

### Fixed

- Fix android special character escaping [#56](https://github.com/applidium/ad_localize/issues/56)
- Fix platform filter on export [#55](https://github.com/applidium/ad_localize/issues/55)

### Changed

- Use default terminal color for debug log

## [4.0.3] - 2020-10-27

### Fixed

- Fix CSV detection and remove dependency to MimeType gem
- Fix drive key detection in options

## [4.0.2] - 2020-10-26

### Fixed

- Use percent HTML char for escaping '%' on android. [#49](https://github.com/applidium/ad_localize/pull/49)
  by [flolom](https://github.com/flolom)

## [4.0.1] - 2020-10-19

### Fixed

- delete downloaded files even when any of them is a CSV file

## [4.0.0] - 2020-10-19

### Breaking change

- Precedence to csv files. Only CSV files will be exported if both csv file and google spreadsheet are provided
- In case of multiple CSVs or sheet ids, you should be aware that all sources will be merged. By default the merge
  policy to keep the first wording translation for each key
- New architecture. Separate export process responsibilities in dedicated classes.
  Fixes [#48](https://github.com/applidium/ad_localize/issues/48)
  , [#20](https://github.com/applidium/ad_localize/issues/20)

### Changed

- it is now possible to provide an output path path that does not exist
- if a service account configuration is provided, there won't be any files downloaded
- it is now possible to provide a sheet id list
- `ActiveSupport::TestCase` is now the base class of test classes
- Only global constants are in the constant class
- Replaced the Runner class file by a cli class
- tests for ad_localize class are restricted to the minimum
- No more file generated when there are no data to export
- Less verbose logs. Now, they only describe the different steps of the export process
- do not add `InfoPlist` translations to android `strings.xml`

### Added

- -e, -export_all_sheets option export all sheets from a spreadsheet by [@sjcqs](https://github.com/sjcqs)
- -m, --merge-option to select the merge policy (`keep` or `replace`) by [@sjcqs](https://github.com/sjcqs)
- it is now possible to select which locales you want to export
- key class is tested
- option handler is tested
- execute_export_request is tested (only csv)
- export request is tested
- dedicated folder for fixture files
- add ability to use AdLocalize in a Ruby program
- add documentation for JSON and YAML support. Fixes [#23](https://github.com/applidium/ad_localize/issues/23)

### Fixed

- comments will now be added to iOS and Android plural files
- do not remove existing files in export output folder. Fixes [#40](https://github.com/applidium/ad_localize/issues/40)

### Removed

- no more option -a option to indicate that a service account configuration will be provided. If set, the environment
  variable `GCLOUD_CLIENT_SECRET` content will be used
- no more substitution of empty wording with by "Missing Translation" when using the option -d
- no more Makefile, the Rakefile is sufficient. Use `bundle exec rake -T` to display the available commands
- no more check for ordered interpolation variables in translations

## [3.6.0] - 2020-06-23

### Added

- add documentation for service account usage by [@sjcqs](https://github.com/sjcqs)
- add compatibility with activesupport 6 by [@Hugo-Hache](https://github.com/Hugo-Hache)

### Changed

### Fixed

## [3.5.0] - 2020-05-12

### Added

- add support for private spreadsheet using google service acccount by [@sjcqs](https://github.com/sjcqs).
  Fixes [#31](https://github.com/applidium/ad_localize/issues/31)
- add makefile for easier testing by [@felginep](https://github.com/felginep)

### Changed

- improve error message to have useful information in case of google spreadsheet use
  by [@felginep](https://github.com/felginep). Fixes [#27](https://github.com/applidium/ad_localize/issues/27)
- platform folder is no longer generated when there is only one platform selected. The files are directly generated in
  the output path. By [@felginep](https://github.com/felginep).
  Fixes [#29](https://github.com/applidium/ad_localize/issues/29)
- raise error when google spreadsheet key is invalid by [@felginep](https://github.com/felginep)

### Fixed

- auto escape strings in Localizable.strings by [@felginep](https://github.com/felginep).
  Fixes [#26](https://github.com/applidium/ad_localize/issues/26)
- trim keys to prevent user error by [@felginep](https://github.com/felginep).
  Fixes [#16](https://github.com/applidium/ad_localize/issues/16)

## [3.4.0] - 2019-02-10

### Added

- Rails folks, [@epaillous](https://github.com/epaillous) has improved the YAML support. You can now have multi-level
  wording.

## [3.3.0] - 2019-02-10

### Added

- improve React support using keys with dots to generate nested JSON files by [@epaillous](https://github.com/epaillous)

## [3.2.0] - 2019-12-10

### Added

- Add tests to compare reference exports by [@felginep](https://github.com/felginep)
- [iOS only]
  Handle [adaptive strings](https://developer.apple.com/documentation/foundation/nsstring/1413104-variantfittingpresentationwidth)
  by [@felginep](https://github.com/felginep)

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
