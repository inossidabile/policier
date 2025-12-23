# frozen_string_literal: true

module Policier
  module Evaluators
    class ArelEvaluator < Evaluator
      def initialize(policy, evaluable)
        super
        @total_scope = evaluable.none
      end

      def query
        @evaluable
      end

      def to(*scopes)
        scopes.each do |scope|
          @total_scope = @total_scope.or(scope)
        end
      end

      def to_sql
        @total_scope.to_sql
      end

      def enforce(&block)
        proc do
          @total_scope.scoping(all_queries: true, &block)
        end
      end
    end
  end
end
