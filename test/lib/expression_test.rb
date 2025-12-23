# frozen_string_literal: true

require "test_helper"

module Policier
  class ExpressionTest < PolicierSpec
    class ConditionA < Condition
      verify do
        pass
      end
    end

    class ConditionB < Condition
      verify do
        pass
      end
    end

    class ConditionC < Condition
      verify do
        deny!
      end
    end
    describe "merging" do
      it "or_over_brackets_and" do
        Policy.enforce test: true do
          result = ConditionA | (ConditionB * ConditionC)
          _(result).must_be_instance_of Expression
          _(result.evaluate(Context.policy)).must_equal true
        end
      end

      it "and" do
        Policy.enforce test: true do
          result = ConditionB * ConditionC
          _(result).must_be_instance_of Expression
          _(result.evaluate(Context.policy)).must_equal false
        end
      end

      it "or_duplicated_and" do
        Policy.enforce test: true do
          result = ConditionC | (ConditionB * ConditionC)
          _(result).must_be_instance_of Expression
          _(result.evaluate(Context.policy)).must_equal false
        end
      end
    end
  end
end
