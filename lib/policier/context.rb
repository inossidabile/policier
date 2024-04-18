# frozen_string_literal: true

require "dry/inflector"

require_relative "condition_union"
require_relative "stack"

module Policier
  class Context
    class NotInScopeException < StandardError; end

    THREAD_KEY = :policier_context

    class << self
      def current
        Thread.current[THREAD_KEY]
      end

      def start
        Thread.current[THREAD_KEY] = Context.new
      end

      def cleanup
        Thread.current[THREAD_KEY] = nil
      end

      def scope(**payload, &block)
        current.scope(**payload, &block)
      end
    end

    attr_reader :stack

    def initialize
      @stack = Stack.new
      @conditions = {}
      @data = {}
    end

    def payload
      @stack.payload
    end

    def scope(**payload)
      stack.push(**payload)

      begin
        yield
      ensure
        removed_payload_keys = stack.pop
        @conditions.each_key do |condition_class|
          if (condition_class.required_keys & removed_payload_keys).any?
            @conditions.delete(condition_class)
            @data.delete(condition_class)
          end
        end
      end
    end

    def init_data(condition_class, data_class)
      @data[condition_class] = data_class.new
    end

    def ensure_condiiton(condition_class)
      @conditions[condition_class] ||= condition_class.new.verify
    end

    def known_conditions
      @conditions.keys
    end

    def mock_condition(*condtion_classes, failed: false, data_replacement: {})
      condtion_classes.each do |condition_class|
        @condition[condition_class] ||= condition_class.new.override!(
          failed: failed,
          data_replacement: data_replacement
        )
      end
    end
  end
end
