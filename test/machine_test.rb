require_relative 'helper'
require_relative 'door_state_machine'

describe Aquam::Machine do
  before do
    @door = Door.new
    @machine = @door.machine
  end

  describe 'valid_*? methods' do
    it 'returns a boolean if is a valid state' do
      assert @machine.valid_state?

      @door.state = :wrong_state

      deny @machine.valid_state?
    end

    it 'returns a boolean if is a valid event' do
      assert @machine.valid_event? :open
      deny @machine.valid_event? :lock
    end

    it 'returns a boolean if is a valid transition from the current state' do
      deny @machine.valid_transition? :close
      assert @machine.valid_transition? :open
    end
  end

  describe 'current_state' do
    it 'returns an instance of the current state object' do
      assert @machine.current_state.instance_of? ClosedDoorState

      @door.state = :opened

      assert @machine.current_state.instance_of? OpenedDoorState
    end

    it 'fails if the current state was not defined into the machine' do
      assert_raises Aquam::InvalidStateError do
        @door.state = :must_fail
        @machine.current_state
      end
    end
  end

  describe 'trigger' do
    it 'fires the event and returns the new state' do
      assert @machine.current_state.instance_of? ClosedDoorState

      new_state = @machine.trigger(:open)

      assert new_state.instance_of? OpenedDoorState
    end

    it 'fails if is not a valid event' do
      assert_raises Aquam::InvalidEventError do
        @machine.trigger :lock
      end
    end

    it 'fails if is not a valid transition' do
      assert_raises Aquam::InvalidTransitionError do
        @machine.trigger :close
      end
    end
  end
end
