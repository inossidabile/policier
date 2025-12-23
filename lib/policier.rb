# frozen_string_literal: true

require "active_support/all"

require_relative "policier/version"
require_relative "policier/context"
require_relative "policier/policy"
require_relative "policier/condition"

module Policier
  class Error < StandardError; end
  # Your code goes here...
end
