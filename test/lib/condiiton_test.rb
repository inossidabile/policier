# frozen_string_literal: true

require "test_helper"

module Policier
  class ConditionTest < PolicierSpec
    class ConditionA < Condition
      self.data_class = Struct.new(:foo, :bar)

      verify_with :test do
        fail! unless payload.key?(:foo)
      end

      also_ensure(:has_bar) do |data|
        fail! unless data.key?(:bar)
      end

      also_ensure(:has_baz) do |data|
        fail! unless data.key?(:baz)
      end
    end

    class ConditionB < Condition
      verify_with :test do
        depend_on! ConditionA
      end
    end

    def test_name
      assert_equal :policier_condition_test_condition_a, ConditionA.handle
    end

    describe "without ensure" do
      def test_successful_condition
        Context.scope test: true, foo: "bar", bar: :baz do
          condition = ConditionA.new

          assert condition.verify
          assert !condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition
        Context.scope test: true do
          condition = ConditionA.new

          assert condition.verify
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end
    end

    describe "with one ensure" do
      def test_successful_condition
        Context.scope test: true, foo: "bar", bar: :baz do
          condition = ConditionA.new

          assert condition.verify.and_has_bar(bar: "foo")
          assert !condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition
        Context.scope test: true do
          condition = ConditionA.new

          assert condition.verify.and_has_bar({})
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition_on_dependent
        Context.scope test: true do
          condition = ConditionB.new

          assert condition.verify
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
        end
      end
    end

    describe "with two ensure" do
      def test_successful_condition
        Context.scope test: true, foo: "bar", bar: :baz do
          condition = ConditionA.new

          assert condition.verify.and_has_bar(bar: "foo").and_has_baz(baz: "foo")
          assert !condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition
        Context.scope test: true do
          condition = ConditionA.new

          assert condition.verify.and_has_bar({})
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition_on_second_step
        Context.scope test: true do
          condition = ConditionA.new

          assert condition.verify.and_has_bar({}).and_has_baz(baz: "foo")
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end

      def test_failed_condition_on_third_step
        Context.scope test: true do
          condition = ConditionA.new

          assert condition.verify.and_has_bar(bar: "foo").and_has_baz({})
          assert condition.failed?
          assert_equal Context.current.payload, condition.payload
          assert_equal %i[foo bar], condition.data.members
        end
      end
    end
  end
end
