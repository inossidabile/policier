require "test_helper"

module Policier
  class ConditionTest < Minitest::Spec
    class Subject < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with do |context|
        fail! unless context.key?(:foo)

        collector[:foo] = context[:foo]
      end

      also_ensure(:has_bar) do |data|
        fail! unless data.key?(:bar)

        collector[:bar] = data[:bar]
      end

      also_ensure(:has_baz) do |data|
        fail! unless data.key?(:baz)
      end
    end

    def test_name
      assert_equal :policier_condition_test_subject, Subject.handle
    end

    describe "without ensure" do
      def test_successful_condition
        context = { foo: "bar", bar: :baz }
        condition = Subject.new(context)

        assert condition.verify
        assert !condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end

      def test_failed_condition
        context = {}
        condition = Subject.new(context)

        assert condition.verify
        assert condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end
    end

    describe "with one ensure" do
      def test_successful_condition
        context = { foo: "bar", bar: :baz }
        condition = Subject.new(context)

        assert condition.verify.and_has_bar(bar: "foo")
        assert !condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end

      def test_failed_condition
        context = {}
        condition = Subject.new(context)

        assert condition.verify.and_has_bar({})
        assert condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end
    end

    describe "with two ensure" do
      def test_successful_condition
        context = { foo: "bar", bar: :baz }
        condition = Subject.new(context)

        assert condition.verify.and_has_bar(bar: "foo").and_has_baz(baz: "foo")
        assert !condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end

      def test_failed_condition
        context = {}
        condition = Subject.new(context)

        assert condition.verify.and_has_bar({})
        assert condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end

      def test_failed_condition_on_second_step
        context = {}
        condition = Subject.new(context)

        assert condition.verify.and_has_bar({}).and_has_baz(baz: "foo")
        assert condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end

      def test_failed_condition_on_third_step
        context = {}
        condition = Subject.new(context)

        assert condition.verify.and_has_bar(bar: "foo").and_has_baz({})
        assert condition.failed?
        assert_equal context, condition.context
        assert_equal %i[foo bar], condition.collector.members
      end
    end
  end
end
