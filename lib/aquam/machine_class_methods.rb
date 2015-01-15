require_relative 'event_transitions'

module Aquam
  module MachineClassMethods
    def attribute(name = nil)
      name ? @attribute = name : @attribute ||= :state
    end

    def states
      @states ||= {}
    end

    def events
      @event ||= Hash.new { |hash, key| hash[key] = {} }
    end

    def state(name, klass)
      states[name] = klass
    end

    def event(name, &block)
      Aquam::EventTransitions.new self, name, &block
    end

    def transition(from, to, event_name)
      fail Aquam::InvalidStateError if !valid_state?(from) || !valid_state?(to)

      events[event_name][from] = to
    end

    def valid_state?(state)
      states.keys.include? state
    end

    def valid_event?(event)
      events.keys.include? event
    end
  end
end
