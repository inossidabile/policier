# frozen_string_literal: true

require "test_helper"

module Policier
  class ContextTest < Minitest::Spec
    class Condition < Condition
      verify_with { |_| }
    end

    def test_scope
      Context.scope({}) do
        assert_instance_of Context, Context.current
      end
    end

    def test_scope_extension
      Context.scope(foo: "bar") do
        Context.scope(bar: "baz") do
          assert_equal({ foo: "bar", bar: "baz" }, Context.current.payload)
        end
      end
    end
  end
end
