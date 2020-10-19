module AdLocalize
  module Requests
    class MergePolicy
      REPLACE_POLICY = 'replace'.freeze
      KEEP_POLICY = 'keep'.freeze
      MERGE_POLICIES = [KEEP_POLICY, REPLACE_POLICY]
      DEFAULT_POLICY = KEEP_POLICY

      attr_reader(:policy)

      def initialize(policy:)
        @policy = policy
      end

      def keep?
        @policy == KEEP_POLICY
      end

      def replace?
        @policy == REPLACE_POLICY
      end

      def valid?
        @policy.present? && MERGE_POLICIES.include?(@policy)
      end
    end
  end
end