require File.expand_path("../lib/ad_localize/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'ad_localize'
  spec.version       = AdLocalize::VERSION
  spec.date = %q(2018-04-18)
  spec.authors       = [
    'Edouard Siegel',
    'Patrick Nollet',
    'Adrien Couque',
    'Tarek Belkahia',
    'Hugo Hache',
    'Vincent Brison',
    'Joanna Vigné',
    'Nicolas Braun',
    'Corentin Huard',
    'Claire Peyron'
  ]
  spec.email         = ['joanna.vigne@fabernovel.com', 'hugo.hache@fabernovel.com', 'edouard.siegel@fabernovel.com']

  spec.summary       = %q{ AdLocalize }
  spec.description   = %q{ Convert a wording file in localization files. Supported export formats are : iOS, Android,
   JSON and YAML }
  spec.homepage      = 'https://technologies.fabernovel.com'
  spec.license       = 'MIT'

  spec.files = %w(
    lib/ad_localize.rb
    lib/ad_localize/ad_logger.rb
    lib/ad_localize/constant.rb
    lib/ad_localize/option_handler.rb
    lib/ad_localize/csv_parser.rb
    lib/ad_localize/csv_file_manager.rb
    lib/ad_localize/runner.rb
    lib/ad_localize/platform/android_formatter.rb
    lib/ad_localize/platform/ios_formatter.rb
    lib/ad_localize/platform/json_formatter.rb
    lib/ad_localize/platform/platform_formatter.rb
    lib/ad_localize/platform/yml_formatter.rb
  )
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_dependency 'json', '~> 1.8', '>= 1.8.3'
  spec.add_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'
  spec.add_dependency 'activesupport', '>=4.2.10'
  spec.add_dependency 'colorize', '~> 0.8.1'

  spec.executables << 'ad_localize'
end
