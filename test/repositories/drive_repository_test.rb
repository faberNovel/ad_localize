# frozen_string_literal: true
require 'test_helper'

module AdLocalize
  module Repositories
    class DriveRepositoryTest < TestCase
      test 'download public sheets' do
        spreadsheet_id = '10tmRtgFi1hG53fCcTTHgBjS5or_eCrHkwq4kJCLrYRA'
        sheet_ids = %w[0 153850430]
        files = DriveRepository.new.download_sheets_by_id(spreadsheet_id: spreadsheet_id, sheet_ids: sheet_ids)
        assert_equal 2, files.size
        assert_not_equal files.first.read, files.second.read
        files.each do |file|
          assert file.size > 0
        end
      end

      test 'download all sheets in public spreadsheet' do
        spreadsheet_id = '10tmRtgFi1hG53fCcTTHgBjS5or_eCrHkwq4kJCLrYRA'
        files = DriveRepository.new.download_all_sheets(spreadsheet_id: spreadsheet_id)
        assert_empty files
      end

      test 'handle error on download specific sheets' do
        spreadsheet_id = '10tmRtgFi1hG53fCcTTHgBjS5or_eCrHkwq4kJCLrYRA'
        fake_sheet_ids = %w[-2 -1]
        files = DriveRepository.new.download_sheets_by_id(
          spreadsheet_id: spreadsheet_id,
          sheet_ids: fake_sheet_ids
        )
        assert_empty files
      end

      test 'handle error on download all sheets in spreadsheet' do
        spreadsheet_id = 'this_is_a_fake_spreadsheet_id'
        files = DriveRepository.new.download_all_sheets(spreadsheet_id: spreadsheet_id)
        assert_empty files
      end
    end
  end
end
