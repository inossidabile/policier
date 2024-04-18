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
  end
end
