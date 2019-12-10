# AdLocalize

The purpose of this gem is to automatically generate wording files from a csv input (local file or google spreadsheet). It is a useful tool when working on a mobile application or a SPA.

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
$ bundle exec ad_localize -h
```

* Export wording from a google drive spreadsheet, using the file key
```
$ bundle exec ad_localize -k <your-spreadsheet-drive-key>
```
* Export wording from a google drive spreadsheet, using the file key and specifying a sheet (useful when your file has multiple sheets)
```
$ bundle exec ad_localize -k <your-spreadsheet-drive-key> -s <your-specific-sheet-id>
```

* Only generate wording files for the specified platforms
```
$ bundle exec ad_localize -o ios
```

* Choose the path of the output directory
```
$ bundle exec ad_localize -t <path-to-the-output-directory>
```

* Run in debug mode. In this mode, logs are more verbose and missing values are replaced with "<Missing Translation>"
```
$ bundle exec ad_localize -d
```

### CSV file
#### General syntax rules

| key | fr | en |
| --- | --- | --- |
| agenda | agenda | events |
| favorites | Mes favoris | My favorites |
| from_to | du %1$@ au %2$@ | from %1$@ to %2$@ |

- Any column after the `key` column will be considered as a locale column (except from the optional `comment columns) 
- Keys should be written in Android format : [a-z0-9_]+
- Format specifiers must be numeroted if there are more than one in a translation string (eg: "%1$@ %2$@'s report").

#### Comment columns

In iOS (and only iOS) you can add a comment to a missing translation.

| key | fr | comment fr | en | comment en |
| --- | --- | --- | --- | --- |
| player_time_live | Live | bypass-unused-error | Live | bypass-unused-error |
| seconds | secondes |  | seconds | bypass-untranslated-error |

The comment will be written in the output files  such as below:

```
"player_time_live" = "Live"; // bypass-unused-error
"seconds" = "seconds"; // bypass-untranslated-error
```

## Output

The output folder name is `exports` and it contains a folder for each platform and each locale. In the best case, you just have to replace your existing files with the new ones.

Eg:
```
exports/
├── android
│   ├── values
│   │   └── strings.xml
│   └── values-en
│       └── strings.xml
├── ios
│   ├── en.lproj
│   │   ├── Localizable.strings
│   │   ├── Localizable.stringsdict
|   |   └── InfoPlist.strings
│   └── fr.lproj
│       ├── Localizable.strings
│       ├── Localizable.stringsdict
|       └── InfoPlist.strings
├── json
│   ├── en.json
│   └── fr.json
└── yml
    ├── en.yml
    └── fr.yml
```

## Plurals

Plurals are supported for iOS and Android.

Syntax for plural keys in the CSV file:

       key##{few}
       key##{one}
       key##{other}
       …

Sample of Android output in strings.xml

```xml
<resources>
  <plurals name="cake">
    <item quantity=["zero"|"one"]>gateau</item>
    <item quantity="other">gateaux</item>
  </plural>
</resources>
```

Sample of iOS output in .stringsdict

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist>
    <dict>
        <key>traveller_type_child_title</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@key@</string>
            <key>key</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>d</string>
                <key>zero</key>
                <string/>
                <key>one</key>
                <string>1 enfant</string>
                <key>two</key>
                <string/>
                <key>few</key>
                <string/>
                <key>many</key>
                <string/>
                <key>other</key>
                <string>%d enfants</string>
            </dict>
        </dict>
    </dict>
</plist>
```

## InfoPlist.strings

_Only for iOS._

Every key that matches the following formats will be added to the `InfoPlist.strings` file instead of `Localizable.strings`:
* `NS...UsageDescription`
* `CF...Name`

Source: https://developer.apple.com/documentation/bundleresources/information_property_list

## Adaptive strings

_Only for iOS._

Syntax for adaptive keys in the CSV file:

       key##{20}
       key##{25}
       key##{50}
       …

Sample of iOS output in .stringsdict

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist>
    <dict>
        <key>start_countdown</key>
        <dict>
            <key>NSStringVariableWidthRuleType</key>
            <dict>
                <key>20</key>
                <string>Start</string>
                <key>25</key>
                <string>Start countdown</string>
                <key>50</key>
                <string>Start countdown</string>
            </dict>
        </dict>
    </dict>
</plist>
```

Source: https://developer.apple.com/documentation/foundation/nsstring/1413104-variantfittingpresentationwidth

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/applidium/ad_localize. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AdLocalize project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ad_localize/blob/master/CODE_OF_CONDUCT.md).
