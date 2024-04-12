require "dry/inflector"

require_relative "condition_union"

module Policier
  class Runner
    module DSL
      def scope(model, &block)
        @model = model
        @scope = block
      end

      def run(context, condition_classes: nil)
        runner = Runner.new(context, @model, condition_classes: condition_classes)
        runner.instance_eval(&@scope)
        runner.scope_union
      end
    end

    attr_reader :scope_union

    def initialize(context, model, condition_classes: nil)
      @scope_union = ScopeUnion.new(model)

      condition_classes ||= Condition.all
      condition_classes.each do |condition_class|
        instance_variable_set("@#{condition_class.handle}", condition_class.new(context).verify)
      end
    end

    def allow(condition_union, &block)
      condition_union.union.conditions.each do |condition|
        @scope_union.instance_exec(condition.collector, condition, &block)
      end
    end
  end
end
