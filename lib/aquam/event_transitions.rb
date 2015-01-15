module Aquam
  class EventTransitions
    def initialize(machine, event_name, &block)
      @machine    = machine
      @event_name = event_name
      instance_eval(&block)
    end

    def transition(from:, to:)
      @machine.transition(from, to, @event_name)
    end
  end
end
