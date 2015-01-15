module Aquam
  class State
    # I have to use a class variable because it **must** be the same value
    # across all the children calsses.
    #
    # Also I need it defined always
    @@state_machine = nil

    def self.state_machine(state_machine = nil)
      if state_machine && !@@state_machine
        validate_state_machine state_machine

        @@state_machine = state_machine
        define_event_methods
      end

      @@state_machine
    end

    def initialize(object)
      @object = object
    end

    def state_machine
      self.class.state_machine || fail(Aquam::InvalidStateMachineError)
    end

    private

    def self.define_event_methods
      state_machine.events.keys.each do |event|
        define_method event do
          fail Aquam::InvalidTransitionError
        end
      end
    end
    private_class_method :define_event_methods

    def self.validate_state_machine(state_machine)
      unless state_machine.ancestors.include? Aquam::Machine
        fail Aquam::InvalidStateMachineError
      end
    end
    private_class_method :validate_state_machine
  end
end
