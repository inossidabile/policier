# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "policier"

require "minitest/autorun"
require "pry"

class PolicierSpec < Minitest::Spec
  # def before_setup
  #   Policier::Context.start
  #   super
  # end

  # def after_teardown
  #   super
  #   Policier::Context.cleanup
  # end
end
