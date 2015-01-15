module Aquam
  class InvalidStateError < StandardError; end
  class InvalidEventError < StandardError; end
  class InvalidTransitionError < StandardError; end
  class InvalidStateMachineError < StandardError; end

  class FailedTransitionError < StandardError
    attr_reader :errors

    def initialize(errors = {})
      @errors = errors
    end
  end
end
