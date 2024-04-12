module Policier
  class ScopeUnion
    attr_reader :scope

    def initialize(model)
      @model = model
      @scope = model.none
    end

    def to(scope)
      @scope = @scope.or(scope)
    end
  end
end
