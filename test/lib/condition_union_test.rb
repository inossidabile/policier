# frozen_string_literal: true

require "test_helper"

module Policier
  class ConditionUnionTest < PolicierSpec
    class ConditionA < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with :test do |_context|
      end
    end

    class ConditionB < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with :test do |_context|
      end
    end

    class ConditionC < Condition
      self.collector = Struct.new(:foo, :bar, :baz)

      verify_with :test do |_context|
        fail!
      end
    end

    describe "merging" do
      def test_one_condition_unions
        Context.scope test: true do
          result = ConditionA.union
          _(result).must_be_instance_of ConditionUnion
          _(result.conditions.length).must_equal 1
        end
      end

      def test_two_condition_union
        Context.scope test: true do
          result = ConditionA | ConditionB
          _(result).must_be_instance_of ConditionUnion
          _(result.conditions.length).must_equal 2
        end
      end

      def test_three_condition_union
        Context.scope test: true do
          result = ConditionA | ConditionB | ConditionC
          _(result).must_be_instance_of ConditionUnion
          _(result.conditions.length).must_equal 3
        end
      end
    end
  end
end
