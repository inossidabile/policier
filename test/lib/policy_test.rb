# frozen_string_literal: true

require "test_helper"

module Policier
  class PolicyTest < Minitest::Spec
    class ConditionA < Condition
      self.collector = Struct.new(:history)

      verify_with do |context|
        collector[:history] = context[:history]
      end
    end

    class ConditionB < Condition
      self.collector = Struct.new(:history)

      verify_with do |context|
        collector[:history] = context[:history]
      end
    end

    class ConditionC < Condition
      self.collector = Struct.new(:history)

      verify_with do |context|
        collector[:history] = context[:history]
        fail!
      end
    end

    class Model < ActiveRecord::Base; end

    class Subject < Policy
      scope(Model) do
        allow @policier_policy_test_condition_a do |collector, condition|
          collector[:history] << condition
        end

        allow @policier_policy_test_condition_b | @policier_policy_test_condition_a do |collector, condition|
          collector[:history] << condition
        end

        allow @policier_policy_test_condition_c | @policier_policy_test_condition_b do |collector, condition|
          collector[:history] << condition
        end
      end
    end

    def test_policy_arithmetics
      history = []

      Subject.run({ history: history }, condition_classes: [ConditionA, ConditionB, ConditionC])

      _(history.map(&:class)).must_equal([ConditionA, ConditionB, ConditionA, ConditionB])
    end
  end
end
