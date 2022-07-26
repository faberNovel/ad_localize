$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ad_localize"

require "minitest/autorun"
require 'active_support/testing/declarative'
require "minitest/reporters"
require 'diffy'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class TestCase < ActiveSupport::TestCase
  DEFAULT_LANGUAGES = %w(fr en)
  DEFAULT_IOS_FILES = %w(InfoPlist.strings Localizable.strings Localizable.stringsdict)
end