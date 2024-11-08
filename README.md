# AdLocalize

The purpose of this gem is to automatically generate wording files from a CSV input (CSV file or Google Spreadsheet).
It supports iOS, Android, JSON, YAML and Java Properties.
It is a useful tool when working on a mobile application or a SPA.

## Migration from 5.x to 6.0.0

When using the CLI replace `GCLOUD_CLIENT_SECRET=$(cat <path-to-client-secret.json>)` with `GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secret.json>`  
When using the interactor refer to [ruby program usage section](###In-a-Ruby-program)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ad_localize'
```

And then execute:
```
$ bundle install
```

Or install it yourself as:
```
$ gem install ad_localize
```

## Usage

### Command Line

* Display help
```
$ ad_localize -h
```

* Export wording from a public google spreadsheet, default tab. The spreadsheet key and sheet_id are available in the spreadsheet url. For example `https://docs.google.com/spreadsheets/d/<your-spreadsheet-drive-key>/edit#gid=<sheet-id>`.
```
$ ad_localize -k <your-spreadsheet-drive-key>
```

* Export wording from a set of google spreadsheet tabs.
```
$ ad_localize -k <your-spreadsheet-drive-key> -s <comma-separated-sheet-id-list>
```

* Export wording from a private google spreadsheet. It requires a [Google Cloud Service Account](#using-a-google-cloud-service-account).
```
$ GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secret.json> ad_localize -k <your-spreadsheet-drive-key>
```

* Export wording from all sheets in a google spreadsheet. It requires a [Google Cloud Service Account](#using-a-google-cloud-service-account).
```
$ GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secret.json> ad_localize -k <your-spreadsheet-drive-key> -e
```

* Only generate wording files for the specified platforms
```
$ ad_localize -o ios
```

* Choose the path of the output directory
```
$ ad_localize -t <path-to-the-output-directory>
```

* Run in debug mode. In this mode, logs are more verbose
```
$ ad_localize -d
```

* Won't generate keys with empty values (iOS feature only, automatically handled for Android)
```
$ ad_localize -x
```

* Will escape % character present in wordings (iOS feature only), this is useful when using the wording through String(format:)
```
$ ad_localize --auto-escape-percent
```

* Only generate wording files for the specified locales
```
$ ad_localize -l fr,en
```

* Keep extra spaces before and after translated values
```
$ ad_localize --skip-value-stripping
```

### In a Ruby program
There are many possibilities when using AdLocalize in a ruby program. You can add support to your own wording format, support other platforms, select which locales you want to export, generate wording file content without writing on the disk and many more.

Here is an example of how to use it to produce the same output as the command line.
If you want more examples, please open a documentation issue.

```Ruby
    require 'ad_localize'
    # create export request
    export_request = Requests::ExportRequest.new
    export_request.spreadsheet_id = 'some_id'
    export_request.sheet_ids = %w[first second]
    export_request.verbose = true
    begin
        # download files - be sure that GOOGLE_APPLICATION_CREDENTIALS is set if you use service account
        export_request.downloaded_csvs = AdLocalize::Interactors::DownloadSpreadsheets.new.call(export_request: export_request)
        # execute request
        AdLocalize::Interactors::ProcessExportRequest.new.call(export_request: export_request)
    ensure
        export_request.downloaded_csvs.each do |file|
            file.close
            file.unlink
        end
    end
```

## Accessing a google spreadsheet
### Share to anyone with the link

If you do not have high security concerns, the simplest way to access a google spreadsheet is to allow **anyone** with the link to **view** it and enable the `Viewers and commenters can see the option to download, print, and copy` option in the spreadsheet sharing settings.

### Use a Google Cloud Service Account

To use a private google spreasheet you need to use a Google Cloud Service Account. Here are the steps to follow :
1. Create a GCloud Service Account:
    - Go to [Google Cloud Console](https://console.cloud.google.com/)
    - Either create a new project or use an existing one (when using Firebase, a GCloud project is created)
    - Go to *IAM & Admin / Service Account* and create a new service account.
    - Store the created `client-secret.json` (in a password manager for example)
2. Enable Google Spreadsheet API for the project
    - Go to *API / Library* and enable the **Google Spreadsheet API** there.
3. Add the service account to a spreadsheet.
    - In *IAM & Admin / Service Account*, the service account's email is listed. Invite it to the spreadsheet to export.

```
$ GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secrets> ad_localize -k # one way
$ GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secrets> ad_localize -k <your-spreadsheet-drive-key> -s <comma-separated-sheet-id-list> # another way
```

```
$ export GOOGLE_APPLICATION_CREDENTIALS=<path-to-client-secrets>
$ ad_localize -k <your-spreadsheet-drive-key> # one way
$ ad_localize -k <your-spreadsheet-drive-key> -s <comma-separated-sheet-id-list> # another way
```

## Wording syntax
### General syntax rules

| key | fr | en |
| --- | --- | --- |
| # General |  |  |
| agenda | agenda | events |
| favorites | Mes favoris | My favorites |
| from_to | du %1$@ au %2$@ | from %1$@ to %2$@ |

- Any column after the `key` column will be considered as a locale column (except from the optional `comment` columns)
- Keys should contain only letter, number, underscore and dot : [a-z0-9_.]+.
- Format specifiers must be numeroted if there are more than one in a translation string (eg: `"%1$@ %2$@'s report"`).
- _Only for Android_ keys without translation won't be considered
- Lines starting with a comment will be ignored

### Comments

_Only for Android and iOS_

To add comments for iOS or Android, simply add a comment column using the naming convention `comment <locale>`.
Comments are available in `strings.xml`, `Localizable.strings`, `Localizable.stringsdict`, `InfoPlist.strings`. Here is an example for `InfoPlist.strings` :

| key | en | comment en |
| --- | --- | --- |
| player_time_live | Live | bypass-unused-error |
| seconds | seconds | bypass-untranslated-error |

```
"player_time_live" = "Live"; // bypass-unused-error
"seconds" = "seconds"; // bypass-untranslated-error
```

### Key with plural notation

_Only for Android and iOS_

Syntax for plural keys in the CSV file: `key##{text}`.

| key | fr |
| --- | --- |
| assess_rate_trip_voiceover##{one} | Rate %1$@ star |
| assess_rate_trip_voiceover##{other} | Rate %1$@ stars |

### String interpolation mapping

_Only for Android_

If you want to share a spreadsheet between iOS and Android, you can write the wording using the iOS string interpolation convention.
The translation to android convention will be done automagically.

### Adaptive strings

_Only for iOS_

Syntax for [adaptive keys](https://developer.apple.com/documentation/foundation/nsstring/1413104-variantfittingpresentationwidth) in the CSV file: `key##{number}`.

| key | fr |
| --- | --- |
| start_countdown##{20} | Start |
| start_countdown##{25} | Start countdown |
| start_countdown##{50} | Start countdown |

### InfoPlist.strings

_Only for iOS._

Every key that matches the following formats will be added to the `InfoPlist.strings` file instead of `Localizable.strings`:
* `NS...UsageDescription`
* `NFCReaderUsageDescription`
* `CF...Name`

### Nested wording

_Only for YAML and JSON_

For these two platforms it is common to have nested wording files, either to handle plural or to group wording by sections. To handle this behavior in a simple way you should use dots in the key to separate the different levels. For example :

| key | fr |
| --- | --- |
| login.password | mot de passe |
| login.email | email |

```json
{"login":{"password":"mot de passe","email":"email"}}
```

```yaml
fr:
  login:
    password: "mot de passe"
    email: "email"
```


## Output

The default output folder name is `exports`.
If your export is for multiple platforms there will be an intermediate folder for each platform, otherwise the wording files (and folders) will directly be generated in the export folder.
Any existing file will be overriden.
You can see examples of generated files in `test/fixtures/export_references/`

Here an export tree example for all supported platforms in `fr` and `en`:
```
exports/
├── android
│   ├── values
│   │   └── strings.xml
│   └── values-en
│       └── strings.xml
├── ios
│   ├── en.lproj
│   │   ├── InfoPlist.strings
│   │   ├── Localizable.strings
│   │   └── Localizable.stringsdict
│   └── fr.lproj
│       ├── InfoPlist.strings
│       ├── Localizable.strings
│       └── Localizable.stringsdict
├── json
│   ├── en.json
│   └── fr.json
├── properties
│   ├── en.properties
│   └── fr.properties
└── yml
    ├── en.yml
    └── fr.yml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To see all available commands run `bundle exec rake -T` .

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/applidium/ad_localize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## How to release a new version

1. After all your changes are reviewed and merged
2. Create a `release` branch
3. Update the version in `lib/ad_localize/version.rb`
4. Execute `make publish`

You may need to configure your account at step `4.` if you've never pushed any gem. You can find all the informations you need on [the official documentation](https://guides.rubygems.org/make-your-own-gem/#your-first-gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AdLocalize project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ad_localize/blob/master/CODE_OF_CONDUCT.md).
