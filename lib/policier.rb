# frozen_string_literal: true
# frozen_string_literal: tue

require_relative "policier/version"
require_relative "policier/context"
require_relative "policier/policy"
require_relative "policier/runner"
require_relative "policier/condition"
require_relative "policier/condition_union"
require_relative "policier/scope_union"

module Policier
  class Error < StandardError; end
  # Your code goes here...
end
