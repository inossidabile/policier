# frozen_string_literal: true

require "dry/inflector"

require_relative "condition_union"

module Policier
  class Context
    class NotInScopeException < StandardError; end
    class AlreadyInScope < StandardError; end

    THREAD_CURRENT_KEY = :policier_context_current

    class << self
      def current
        raise NotInScopeException unless Thread.current[THREAD_CURRENT_KEY]

        Thread.current[THREAD_CURRENT_KEY]
      end

      def scope(payload)
        raise "Already in scope" if Thread.current[THREAD_CURRENT_KEY].present?

        Thread.current[THREAD_CURRENT_KEY] = new(payload)
        yield
      ensure
        Thread.current[THREAD_CURRENT_KEY] = nil
      end
    end

    attr_reader :payload

    def initialize(payload)
      @payload = payload
      @conditions = {}
      @data = {}
    end

    def init_data(condition_class, data_class)
      @data[condition_class] = data_class.new
    end

    def mock_condition(*condtion_classes, failed: false, data_replacement: {})
      condtion_classes.each do |condition_class|
        @condition[condition_class] ||= condition_class.new.iverride!(
          failed: failed,
          data_replacement: data_replacement
        )
      end
    end

    def ensure_condiiton(condition_class)
      @conditions[condition_class] ||= condition_class.new.verify
    end
  end
end
