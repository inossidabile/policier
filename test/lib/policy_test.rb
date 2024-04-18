# frozen_string_literal: true

require "test_helper"

module Policier
  class PolicyTest < PolicierSpec
    class ConditionA < Condition
      self.data_class = Struct.new(:history)

      verify_with :test do
      end
    end

    class ConditionB < Condition
      self.data_class = Struct.new(:history)

      verify_with :test do
      end
    end

    class ConditionC < Condition
      self.data_class = Struct.new(:history)

      verify_with :test do
        fail!
      end
    end

    class Model < ActiveRecord::Base; end

    class PolicyA < Policy
      scope(Model) do
        allow ConditionA do |condition|
          payload[:history] << condition
        end

        allow ConditionB | ConditionA do |condition|
          payload[:history] << condition
        end

        allow ConditionC | ConditionB do |condition|
          payload[:history] << condition
        end
      end
    end

    def test_policy_arithmetics
      history = []
      Context.scope test: true, history: history do
        PolicyA.run

        _(history.map(&:class)).must_equal([ConditionA, ConditionB, ConditionA, ConditionB])
      end
    end
  end
end
