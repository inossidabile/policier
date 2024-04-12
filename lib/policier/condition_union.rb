# frozen_string_literal: true

module Policier
  class ConditionUnion
    attr_reader :conditions

    def initialize(*conditions)
      @conditions = []
      conditions.each { |c| self | c }
    end

    def |(other)
      @conditions << other unless other.failed?
      self
    end

    def union
      self
    end
  end
end
