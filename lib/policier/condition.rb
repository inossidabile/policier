# frozen_string_literal: true

require "dry/inflector"

require_relative "condition_union"

module Policier
  module ConditionResolve
    def resolve
      Context.current.ensure_condiiton(self)
    end

    def union
      resolve.union
    end

    def |(other)
      union | other
    end
  end

  class Condition
    class FailedException < StandardError; end

    extend ConditionResolve

    class << self
      attr_accessor :data_class
    end

    attr_reader :data

    def initialize
      @context = Context.current
      @data = @context.init_data(self.class, self.class.data_class) if self.class.data_class.present?
      @failed = false
      @executed = false
    end

    def depend_on!(condition_klass)
      condition = condition_klass.resolve
      return fail! if condition.failed?

      condition.data
    end

    def fail!
      raise FailedException
    end

    def payload
      @context.payload
    end

    def failed?
      @failed
    end

    def verify
      return self if @executed

      @failed ||= !instance_exec_with_failures(&self.class.verification_block)
      @executed = true
      self
    end

    def override!(failing: false, data_replacement: {})
      @failed = failing
      @executed = true
      data_replacement.each { |k, v| data[k] = v }
      self
    end

    def instance_exec_with_failures(*args, &block)
      instance_exec(*args, &block)
      true
    rescue FailedException
      false
    end

    def union
      ConditionUnion.new(self)
    end

    class << self
      attr_reader :verification_block
      attr_accessor :collector

      def verify_with(&block)
        @verification_block = block
      end

      def also_ensure(name, &block)
        define_method :"and_#{name}" do |data|
          @failed ||= !instance_exec_with_failures(data, &block)
          self
        end
      end

      def handle
        Dry::Inflector.new.underscore(name).gsub("/", "_").to_sym
      end
    end
  end
end
