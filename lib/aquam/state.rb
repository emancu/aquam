module Aquam
  class State
    def initialize(object)
      @object = object
    end

    def state_machine
      self.class.state_machine || fail(Aquam::InvalidStateMachineError)
    end

    class << self
      def state_machine
        @state_machine
      end

      def use_machine(state_machine)
        @state_machine ||= begin
           validate_state_machine state_machine
           define_event_methods state_machine

           state_machine
         end
      end

      private

      def define_event_methods(machine)
        machine.events.keys.each do |event|
          define_method event do
            fail Aquam::InvalidTransitionError
          end
        end
      end

      def validate_state_machine(machine)
        unless machine && machine.ancestors.include?(Aquam::Machine)
          fail Aquam::InvalidStateMachineError
        end
      end
    end
  end
end
