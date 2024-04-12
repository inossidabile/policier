require "test_helper"

module Policier
  class ConditionUnionTest < Minitest::Spec
    class ConditionA < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with do |_context|
      end
    end

    class ConditionB < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with do |_context|
      end
    end

    class ConditionC < Condition
      self.collector = Struct.new(:foo, :bar, :baz)

      verify_with do |_context|
        fail!
      end
    end

    describe "merging" do
      def test_one_condition_unions
        result = ConditionA.new({}).verify.union
        _(result).must_be_instance_of ConditionUnion
        _(result.conditions.length).must_equal 1
      end

      def test_two_condition_union
        result = ConditionA.new({}).verify | ConditionB.new({}).verify
        _(result).must_be_instance_of ConditionUnion
        _(result.conditions.length).must_equal 2
      end

      def test_three_condition_union
        result = ConditionA.new({}).verify | ConditionB.new({}).verify | ConditionC.new({}).verify
        _(result).must_be_instance_of ConditionUnion
        _(result.conditions.length).must_equal 2
      end
    end
  end
end
