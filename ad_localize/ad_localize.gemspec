require_relative 'lib/ad_localize/version'

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
    'Corentin Huard'
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
    lib/ad_localize/version.rb
    lib/ad_localize/platform_formatters/android_formatter.rb
    lib/ad_localize/platform_formatters/ios_formatter.rb
    lib/ad_localize/platform_formatters/json_formatter.rb
    lib/ad_localize/platform_formatters/platform_formatter.rb
    lib/ad_localize/platform_formatters/yml_formatter.rb
  )
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_dependency 'json', '~> 1.8', '>= 1.8.3'
  spec.add_development_dependency 'byebug', '~> 10.0'
  spec.add_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'
  spec.add_dependency 'activesupport', '~> 5.1', '>= 5.1.5'
  spec.add_dependency 'colorize', '~> 0.8.1'

end
