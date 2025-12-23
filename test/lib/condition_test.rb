# frozen_string_literal: true

require "test_helper"

module Policier
  class ConditionTest < PolicierSpec
    class ConditionA < Condition
      verify do
        deny! if @foo.blank?
        pass
      end

      verify :bar do
        deny! if @bar.blank?
      end

      verify :baz do
        deny! if @baz.blank?
      end
    end

    describe "without_ensure" do
      it "successful_condition" do
        condition = ConditionA.new(test: true, foo: "y")

        assert condition.check!
        assert condition.passed?
      end

      it "failed_condition" do
        condition = ConditionA.new(test: true, foo: nil)

        assert condition.check!
        assert condition.denied?
      end
    end

    describe "with_one_ensure" do
      it "successful_condition" do
        condition = ConditionA[:bar].new(test: true, foo: "bar", bar: :baz)

        assert condition.check!
        assert !condition.denied?
      end

      it "failed_condition" do
        condition = ConditionA[:bar].new(test: true, foo: "y")

        assert condition.check!
        assert condition.denied?
      end
    end
  end
end
