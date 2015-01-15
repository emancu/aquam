require_relative 'helper'
require_relative 'door_state_machine'

describe Aquam::State do
  after do
    DoorState.class_variable_set :@@state_machine, nil
  end

  describe 'state_machine class method' do
    it 'fails if it is not a valid Aquam::Machine class' do
      assert_raises Aquam::InvalidStateMachineError do
        DoorState.state_machine String
      end
    end

    it 'defines the state machine that will be used in the entire hierarchy' do
      assert_equal nil, DoorState.state_machine

      DoorState.state_machine DoorStateMachine

      assert_equal DoorStateMachine, DoorState.state_machine
    end

    it 'defines the state machine for every sublcass' do
      class OpenedDoorState < DoorState; end

      DoorState.state_machine DoorStateMachine

      assert_equal DoorStateMachine, OpenedDoorState.state_machine
      assert_equal DoorStateMachine, OpenedDoorState.new(nil).state_machine
    end

    it 'defines the state machine only once' do
      class WindowStateMachine < Aquam::Machine; end

      DoorState.state_machine DoorStateMachine
      DoorState.state_machine WindowStateMachine

      assert_equal DoorStateMachine, DoorState.state_machine

      Object.send(:remove_const, :WindowStateMachine)
    end

    it 'defines all the events as methods' do
      DoorState.state_machine DoorStateMachine

      assert DoorState.instance_methods.include? :open
      assert DoorState.instance_methods.include? :close
      assert DoorState.instance_methods.include? :knock
    end

    it 'fails by default on every event method' do
      DoorState.state_machine DoorStateMachine

      assert_raises Aquam::InvalidTransitionError do
        DoorState.new(nil).open
      end

      assert_raises Aquam::InvalidTransitionError do
        DoorState.new(nil).close
      end

      assert_raises Aquam::InvalidTransitionError do
        DoorState.new(nil).knock
      end
    end
  end

  describe 'state_machine instance method' do
    it 'returns the state machine class defined' do
      DoorState.state_machine DoorStateMachine

      assert_equal DoorStateMachine, DoorState.new(nil).state_machine
    end

    it 'fails if the state machine was not defined' do
      assert_raises Aquam::InvalidStateMachineError do
        DoorState.new(nil).state_machine
      end
    end
  end
end
