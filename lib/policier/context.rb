# frozen_string_literal: true

require "dry/inflector"

require_relative "condition_union"

module Policier
  class Context
    class NotInScopeException < StandardError; end
    class ScopeStartedEvaluation < StandardError; end
    class DuplicatePayloadKey < StandardError; end

    THREAD_CURRENT_KEY = :policier_context_current

    class << self
      def current
        raise NotInScopeException unless Thread.current[THREAD_CURRENT_KEY]

        Thread.current[THREAD_CURRENT_KEY]
      end

      def scope(payload = {})
        if Thread.current[THREAD_CURRENT_KEY].present? && Context.current.evaluation_started?
          raise ScopeStartedEvaluation
        end

        if Thread.current[THREAD_CURRENT_KEY].blank?
          Thread.current[THREAD_CURRENT_KEY] = new(payload)
        else
          raise ScopeStartedEvaluation if Context.current.evaluation_started? && payload.any?

          Context.current.payload.merge!(payload)
        end

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

    def evaluation_started?
      @conditions.present?
    end

    def ensure_condiiton(condition_class)
      @conditions[condition_class] ||= condition_class.new.verify
    end
  end
end
