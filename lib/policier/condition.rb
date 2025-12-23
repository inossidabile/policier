# frozen_string_literal: true

require_relative "expression"

module Policier
  class Condition
    class_attribute :verify_blocks
    class_attribute :verify_with_block

    def self.resolve(policy)
      policy.ensure_condition(self)
    end

    def self.evaluate(policy) # rubocop:disable Naming/PredicateMethod
      resolve(policy).passed?
    end

    extend Expression::Methods

    def self.verify(name = :default, &block)
      self.verify_blocks ||= {}
      self.verify_blocks[name.to_sym] = block
    end

    def self.verify_with(&block)
      self.verify_with_block = block
    end

    def self.[](verify_name)
      Class.new(self) do
        define_method :check! do
          super(verify_name)
        end
      end
    end

    def initialize(**kwargs)
      kwargs.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      @passed = false
      @finished = false
    end

    def and(other)
      passed? && other
    end

    def or(other)
      passed? || other
    end

    def check!(name = :default) # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      return self if @finished

      if self.class.verify_blocks&.key?(name.to_sym)
        instance_exec(name, &self.class.verify_blocks[name.to_sym])
      elsif self.class.verify_with_block
        instance_exec(name, &self.class.verify_with_block)
      end
      if name != :default && self.class.verify_blocks&.key?(:default)
        instance_exec(name,
                      &self.class.verify_blocks[:default])
      end
      @finished = true

      self
    end

    def pass!
      return if @finished

      @passed = true
      @finished = true
    end

    def deny!
      return if @finished

      @passed = false
      @finished = true
    end

    def pass
      return if @finished

      @passed = true
    end

    def passed?
      check! unless @finished

      @passed
    end

    def denied?
      !passed?
    end
  end
end
