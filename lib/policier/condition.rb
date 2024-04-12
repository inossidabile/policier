require "dry/inflector"

require_relative "condition_union"

module Policier
  class Condition
    class FailedException < StandardError; end

    attr_reader :context, :collector

    def initialize(context)
      @context = context
      @collector = (self.class.collector || Struct.new).new
      @failed = false
    end

    def fail!
      raise FailedException
    end

    def failed?
      @failed
    end

    def verify
      @failed ||= !instance_exec_with_failures(@context, &self.class.verification_block)
      self
    end

    def instance_exec_with_failures(data, &block)
      instance_exec(data, &block)
      true
    rescue FailedException
      false
    end

    def |(other)
      union | other
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
