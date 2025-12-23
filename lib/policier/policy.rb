# frozen_string_literal: true

require_relative "context"
require_relative "evaluators"

module Policier
  class Policy
    class_attribute :evaluables

    attr_reader :values, :conditions, :evaluations

    def self.enforce(*inherit, **values, &block)
      policy = new(*inherit, **values)

      Context.set(policy: policy) do
        policy.enforce(&block)
      end
    end

    def self.restrict(evaluable, &block)
      self.evaluables ||= {}
      self.evaluables[evaluable] = block
    end

    def initialize(*inherit, **values)
      @conditions = {}
      @evaluations = {}
      @evaluated = false

      values = values.merge(Context.policy.values.slice(*inherit)) if inherit.any?
      @values = values
    end

    def evaluate
      return if @evaluated

      return if self.class.evaluables.nil?

      self.class.evaluables.each do |evaluable, block|
        evaluation = evaluable.to_evaluator.new(self, evaluable)
        evaluation.instance_exec(&block)
        @evaluations[evaluable] = evaluation
      end

      @evaluated = true
    end

    def enforce(&block)
      evaluate unless @evaluated

      evaluations.each_value do |evaluation|
        block = evaluation.enforce(&block)
      end

      block.call
    end

    def [](evaluable)
      evaluations[evaluable]
    end

    def ensure_condition(klass)
      @conditions[klass] ||= klass.new(**values)
    end
  end
end
