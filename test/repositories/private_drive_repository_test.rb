# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Repositories
    class PrivateDriveRepositoryTest < TestCase
      test 'download private sheets' do
        spreadsheet_id = '149EE3axc9e0knaCZuf7nTjj0vR7EyRhGgGT3MqWKpwM'
        sheet_ids = %w[0 877315405]
        files = DriveRepository.new.download_sheets_by_id(spreadsheet_id: spreadsheet_id, sheet_ids: sheet_ids)
        assert_equal 2, files.size
        assert_not_equal files.first.read, files.second.read
        files.each do |file|
          assert file.size > 0
        end
      end

      test 'download all sheets in private spreadsheet' do
        spreadsheet_id = '149EE3axc9e0knaCZuf7nTjj0vR7EyRhGgGT3MqWKpwM'
        files = DriveRepository.new.download_all_sheets(spreadsheet_id: spreadsheet_id)
        assert_equal 2, files.size
        assert_not_equal files.first.read, files.second.read
        files.each do |file|
          assert file.size > 0
        end
      end
    end
  end
end
