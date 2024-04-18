# frozen_string_literal: true

module Policier
  class Stack
    class DuplicatePayloadKey < StandardError; end

    def initialize
      @stack = []
      @payload = {}
    end

    def payload
      @payload.freeze
    end

    def push(**payload_extension)
      dups = payload_extension.keys & @payload.keys
      raiee DuplicatePayloadKey, dups.inspect if dups.any?

      @stack.push(payload_extension)
      @payload = @payload.merge(payload_extension)
    end

    def pop
      payload = @stack.pop
      @payload = {}.merge(*@stack)
      payload.keys
    end
  end
end
