module AdLocalize
  module Requests
    class Request
  MergePolicy = Struct.new(:policy) do
    REPLACE_POLICY = 'replace'.freeze
    KEEP_POLICY = 'keep'.freeze
    MERGE_POLICIES = [KEEP_POLICY, REPLACE_POLICY]
    DEFAULT_POLICY = KEEP_POLICY

    def keep?
      policy == KEEP_POLICY
    end

    def replace?
      policy == REPLACE_POLICY
    end

    def valid?
      policy.present? && MERGE_POLICIES.include?(policy)
    end
  end

  ParseOptions = Struct.new(:locales, :bypass_empty_values, :csv_paths, :merge_policy) do
    def valid?
      csv_paths.present?
    end

    def self.default_value
      { locales: [], bypass_empty_values: false, csv_paths: [], merge_policy: MergePolicy::DEFAULT_POLICY }
    end
  end

  ExportOptions = Struct.new(:output_path, :platforms) do
    DEFAULT_EXPORT_FOLDER = 'exports'.freeze

    def valid?
      platforms.present?
    end

    def self.default_value
      { output_path: Pathname.new(DEFAULT_EXPORT_FOLDER) }
    end
  end

  SpreadsheetOptions = Struct.new(:spreadsheet_id, :sheet_ids, :export_all) do
    DEFAULT_SHEET_ID = 0

    def valid?
      spreadsheet_id.present? && (sheet_ids.present? || export_all)
    end

    def self.default_value
      { spreadsheet_id: nil, sheet_ids: [], export_all: false }
    end
  end

  ExportRequest = Struct.new(
    :locales, :bypass_empty_values, :csv_paths, :merge_policy,
    :output_path, :platforms,
    :spreadsheet_id, :sheet_ids, :export_all,
    :verbose) do

    def parse_options
      { locales: locales, bypass_empty_values: bypass_empty_values, csv_paths: csv_paths, merge_policy: merge_policy }
    end
    
    def export_options
      { output_path: output_path }
    end

    def spreadsheet_options
      { spreadsheet_id: spreadsheet_id, sheet_ids: sheet_ids, export_all: export_all }
    end

    def valid?
      parse_options.valid? && export_options.valid? && (spreadsheet_options.nil? || spreadsheet_options.valid?)
    end

    def self.default_value
      {
        locales: [], bypass_empty_values: false, csv_paths: [], merge_policy: MergePolicy::DEFAULT_POLICY,
        output_path: Pathname.new(DEFAULT_EXPORT_FOLDER),
        spreadsheet_id: nil, sheet_ids: [], export_all: false,
        verbose: false
      }
    end
  end

  attr_accessor :parse_options, :export_options, :spreadsheet_options, :verbose
end end end