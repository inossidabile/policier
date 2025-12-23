# frozen_string_literal: true

require "test_helper"

require "active_record"

module Policier
  class PolicyTest < PolicierSpec
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

    class Foo
      def self.to_evaluator
        Evaluators::SymbolEvaluator
      end
    end

    class Model < ActiveRecord::Base
      def self.to_evaluator
        Evaluators::ArelEvaluator
      end
    end

    class PolicyA < Policy
      restrict Foo do
        allow ConditionA do
          to :a
        end

        allow ConditionB do
          to :b
        end

        allow ConditionC do
          to :c
        end
      end
    end

    class PolicyB < Policy
      restrict Model do
        allow ConditionA do
          to query.where(foo: "foo")
        end

        allow ConditionB do
          to query.where(bar: "bar")
        end

        allow ConditionC do
          to query.where(baz: "baz")
        end
      end
    end

    describe "symbols" do
      it "allows" do
        policy = PolicyA.new(test: true)
        policy.evaluate
        assert policy[Foo].allowed?(:a)
        assert !policy[Foo].allowed?(:c)
      end
    end

    describe "arel" do
      before do
        ActiveRecord::Base.establish_connection(
          adapter: "sqlite3",
          database: ":memory:"
        )

        ActiveRecord::Base.connection.create_table(:models) do |t|
          t.string :foo
          t.string :bar
          t.string :baz
        end
      end

      it "allows" do
        policy = PolicyB.new(test: true)
        policy.evaluate
        assert_equal(
          "SELECT \"models\".* FROM \"models\" WHERE (\"models\".\"foo\" = 'foo' OR \"models\".\"bar\" = 'bar')",
          policy[Model].to_sql
        )
      end

      it "enforces" do
        Model.create!(foo: "foo")
        Model.create!(bar: "bar")
        Model.create!(baz: "baz")
        Model.create!(foo: "other")

        PolicyB.enforce(test: true) do
          results = Model.all.to_a
          assert_equal 2, results.size
        end
      end
    end
  end
end
