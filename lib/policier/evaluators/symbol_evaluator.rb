# frozen_string_literal: true

require "set"

module Policier
  module Evaluators
    class SymbolEvaluator < Evaluator
      def initialize(policy, evaluable)
        super
        @allowed = Set.new
      end

      def to(*symbols)
        @allowed.merge(symbols)
      end

      def allowed?(symbol)
        return true if @allowed.include?(:*)

        @allowed.include?(symbol)
      end
    end
  end
end
