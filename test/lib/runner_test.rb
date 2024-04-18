# frozen_string_literal: true

require "test_helper"

module Policier
  class RunnerTest < PolicierSpec
    class SubjectA < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with :test do |_context|
      end
    end

    class SubjectB < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with :test do |_context|
      end
    end

    class SubjectC < Condition
      self.collector = Struct.new(:foo, :bar, :baz)

      verify_with :test do |_context|
        fail!
      end
    end

    class Model < ActiveRecord::Base
    end

    def build_runner(_context = {})
      Policier::Runner.new
    end
  end
end
