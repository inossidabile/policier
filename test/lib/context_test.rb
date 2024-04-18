# frozen_string_literal: true

require "test_helper"

module Policier
  class ContextTest < PolicierSpec
    class ConditionA < Condition
      verify_with :foo do
      end
    end

    class ConditionB < Condition
      verify_with :bar do
      end
    end

    def test_scope_extension
      Context.scope(foo: "bar") do
        Context.scope(bar: "baz") do
          ConditionA.resolve
          assert_equal({ foo: "bar", bar: "baz" }, Context.current.payload)
        end

        assert_equal [ConditionA], Context.current.known_conditions
        assert_equal({ foo: "bar" }, Context.current.payload)
      end
    end
  end
end
