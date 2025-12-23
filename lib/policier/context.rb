# frozen_string_literal: true

module Policier
  class Context < ActiveSupport::CurrentAttributes
    attribute :policy
  end
end
