require "test_helper"

module Policier
  class RunnerTest < Minitest::Spec
    class SubjectA < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with do |_context|
      end
    end

    class SubjectB < Condition
      self.collector = Struct.new(:foo, :bar)

      verify_with do |_context|
      end
    end

    class SubjectC < Condition
      self.collector = Struct.new(:foo, :bar, :baz)

      verify_with do |_context|
        fail!
      end
    end

    class Model < ActiveRecord::Base
    end

    def build_runner(context = {})
      Policier::Runner.new(context, Model, condition_classes: [SubjectA, SubjectB, SubjectC])
    end

    def test_initialize
      runner = build_runner

      _(runner.instance_variables).must_equal(
        %i[@scope_union @policier_runner_test_subject_a @policier_runner_test_subject_b
           @policier_runner_test_subject_c]
      )

      _(runner.instance_variable_get(:@policier_runner_test_subject_c)).must_be_instance_of(SubjectC)
    end
  end
end
