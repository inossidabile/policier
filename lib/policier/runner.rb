# frozen_string_literal: true

require "dry/inflector"

require_relative "condition_union"

module Policier
  class Runner
    module DSL
      def self.extended(_base)
        attr_reader :model
      end

      def scope(model, &block)
        @model = model
        @scope = block
      end

      def run
        runner = Runner.new(self)
        runner.instance_eval(&@scope)
        runner.scope_union
      end
    end

    attr_reader :scope_union

    def initialize(policy)
      @policy = policy
      @scope_union = ScopeUnion.new(policy.model)
    end

    def allow(condition_union, &block)
      condition_union.union.conditions.each do |condition|
        next if condition.failed?

        @scope_union.instance_exec(condition, &block)
      end
    end
  end
end
