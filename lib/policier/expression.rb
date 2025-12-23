# frozen_string_literal: true

module Policier
  class Expression
    module Methods
      def |(other)
        Expression.new(self, other, :or)
      end

      def *(other)
        Expression.new(self, other, :and)
      end
    end

    include Methods

    def initialize(expression, other, operator)
      @expression = expression
      @other = other
      @operator = operator
    end

    delegate :resolve, to: :@expression

    def evaluate(policy)
      resolve(policy).send(@operator, @other.evaluate(policy))
    end
  end
end
