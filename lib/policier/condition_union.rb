# frozen_string_literal: true

module Policier
  class ConditionUnion
    attr_reader :conditions, :context

    def initialize(*conditions)
      @context = Context.current
      @conditions = []
      conditions.each { |c| self | c }
    end

    def |(other)
      other = other.resolve if other.is_a?(Class)
      @conditions << other
      self
    end

    def union
      self
    end

    def payload
      @context.payload
    end
  end
end
