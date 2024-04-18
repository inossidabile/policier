# frozen_string_literal: true

module Policier
  class ScopeUnion
    attr_reader :relation

    def initialize(model = nil)
      @context = Context.current
      @model = model
      @relation = model.none if model.present?
      @visible = false
      @allowed_methods = Set.new
    end

    def can?(method)
      @allowed_methods.include?(method)
    end

    def visible?
      @visible
    end

    def view
      @visible = true
    end

    def scope(update)
      @relation = @relation.or(update)
    end

    def exec(method)
      @allowed_methods.add(method)
    end

    def payload
      @context.payload
    end
  end
end
