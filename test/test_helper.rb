# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ad_localize"

require "minitest/autorun"
require 'active_support/testing/declarative'
require "minitest/reporters"
require 'diffy'
require 'debug'

Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

class TestCase < ActiveSupport::TestCase
  DEFAULT_LANGUAGES = %w[fr en]
  DEFAULT_IOS_FILES = %w[InfoPlist.strings Localizable.strings Localizable.stringsdict]

  def all_files(languages: DEFAULT_LANGUAGES)
    ios_files(languages: languages) +
      android_files(languages: languages) +
      json_files(languages: languages) +
      yml_files(languages: languages) +
      properties_files(languages: languages)
  end

  def ios_files(with_platform_directory: true, languages: DEFAULT_LANGUAGES, files: DEFAULT_IOS_FILES)
    languages
      .map { |language| "#{language}.lproj" }
      .product(files)
      .map { |language_folder, file| "#{language_folder}/#{file}" }
      .map { |file| with_platform_directory ? "ios/#{file}" : file }
  end

  def android_files(languages: DEFAULT_LANGUAGES)
    languages
      .each_with_index
      .map { |language, i| i.zero? ? "values" : "values-#{language}" }
      .map { |language_folder| "android/#{language_folder}/strings.xml" }
  end

  def json_files(languages: DEFAULT_LANGUAGES)
    languages.map { |language| "json/#{language}.json" }
  end

  def yml_files(languages: DEFAULT_LANGUAGES)
    languages.map { |language| "yml/#{language}.yml" }
  end

  def properties_files(languages: DEFAULT_LANGUAGES)
    languages.map { |language| "properties/#{language}.properties" }
  end
end
