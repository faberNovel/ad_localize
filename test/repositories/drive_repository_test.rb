require 'test_helper'

module AdLocalize
    module Repositories
        class DriveRepositoryTest < TestCase
            test 'download public sheets' do
                spreadsheet_id = '10tmRtgFi1hG53fCcTTHgBjS5or_eCrHkwq4kJCLrYRA'
                sheet_ids = %w(0 153850430)
                files = DriveRepository.new.download_sheets_by_id(spreadsheet_id:, sheet_ids:)
                assert_equal 2, files.size
                assert_not_equal files.first.read, files.second.read
                files.each do |file|
                    assert file.size > 0
                end
            end

            test 'download private sheets' do
                spreadsheet_id = '149EE3axc9e0knaCZuf7nTjj0vR7EyRhGgGT3MqWKpwM'
                sheet_ids = %w(0 877315405)
                files = DriveRepository.new.download_sheets_by_id(spreadsheet_id:, sheet_ids:)
                assert_equal 2, files.size
                assert_not_equal files.first.read, files.second.read
                files.each do |file|
                    assert file.size > 0
                end
            end

            test 'download all sheets in public spreadsheet' do
            end

            test 'download all sheets in private spreadsheet' do
            end

            test 'handle error on download specific sheets' do
            end

            test 'handle error on download all sheets in spreadsheet' do
            end
        end
    end
end
