
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ad_localize/version'

Gem::Specification.new do |spec|
  spec.name          = 'ad_localize'
  spec.version       = AdLocalize::VERSION
  spec.license       = 'MIT'
  spec.date          = '2018-04-18'
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
    'Claire Peyron',
    'Claire Dufetrelle',
    'Pierre Felgines',
    'Satyan Jacquens'
  ]
  spec.email         = %w(joanna.vigne@fabernovel.com hugo.hache@fabernovel.com edouard.siegel@fabernovel.com)

  spec.summary       = %q{AdLocalize helps with mobile and web applications wording}
  spec.description   = %q{AdLocalize produces localization files from platform agnostic wording.
                          Supported wording format : CSV. Supported export format: iOS, Android, JSON and YAML}
  spec.homepage      = 'https://github.com/applidium/ad_localize'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.12.0', '< 3.0.0'
  spec.add_development_dependency 'rake', '>= 12.3.0', '< 14.0.0'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'diffy', '~> 3.3'

  spec.add_dependency 'activesupport', '>= 6.1.3.2', '< 8.0'
  spec.add_dependency 'nokogiri', '~> 1.10'
  spec.add_dependency 'colorize', '~> 0.8'
  spec.add_dependency 'googleauth', '~> 0.12'
  spec.add_dependency 'google-apis-sheets_v4', '~> 0.9'

  spec.required_ruby_version = '>= 2.7'
end
