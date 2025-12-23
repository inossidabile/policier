# frozen_string_literal: true

module Policier
  module Evaluators
    class Evaluator
      def self.to_evaluator
        self
      end

      def initialize(policy, evaluable)
        @policy = policy
        @evaluable = evaluable
      end

      def allow(expression, &block)
        return unless expression.evaluate(@policy)

        instance_exec(&block)
      end

      def to(*_args)
        raise NotImplementedError, "Subclasses must implement the `to` method"
      end

      def enforce(&block)
        block
      end
    end
  end
end
