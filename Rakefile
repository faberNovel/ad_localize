# frozen_string_literal: true
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"].exclude("**/private_drive_repository_test.rb")
end

Rake::TestTask.new(:test_private_google_sheet) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/private_drive_repository_test.rb"]
end

task :default => :test
