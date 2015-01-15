require_relative 'machine_class_methods'

module Aquam
  class Machine
    extend Aquam::MachineClassMethods

    attr_accessor :object

    def initialize(object)
      @object = object
    end

    def valid_state?
      self.class.valid_state? attribute
    end

    def valid_event?(event)
      self.class.valid_event? event
    end

    def valid_transition?(event)
      self.class.events[event].key? attribute
    end

    def current_state
      fail Aquam::InvalidStateError unless valid_state?

      self.class.states[attribute].new object
    end

    def trigger(event, *args)
      state = current_state

      fail Aquam::InvalidEventError unless valid_event? event
      fail Aquam::InvalidTransitionError unless valid_transition? event

      state.send event, *args

      current_state
    end

    private

    def attribute
      object.send(self.class.attribute.to_sym).to_sym
    end
  end
end
