$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ad_localize"

require "minitest/autorun"
require 'byebug'
require 'active_support/testing/declarative'
require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class TestCase < Minitest::Test
  extend ActiveSupport::Testing::Declarative
end