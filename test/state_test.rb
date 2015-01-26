require_relative 'helper'
require_relative 'door_state_machine'

describe Aquam::State do
  after do
    OpenedDoorState.instance_variable_set :@state_machine, nil
  end

  describe 'use_machine class method' do
    it 'fails if it is not a valid Aquam::Machine class' do
      assert_raises Aquam::InvalidStateMachineError do
        OpenedDoorState.use_machine String
      end
    end

    it 'defines the state machine that will be used in the state' do
      assert_equal nil, OpenedDoorState.state_machine

      OpenedDoorState.use_machine DoorStateMachine

      assert_equal DoorStateMachine, OpenedDoorState.state_machine
    end

    it 'defines two different state machines for two different states' do
      class OpenedWindowState < Aquam::State; end
      class WindowStateMachine < Aquam::Machine
        state :opened, OpenedWindowState
      end

      OpenedDoorState.use_machine DoorStateMachine
      OpenedWindowState.use_machine WindowStateMachine

      assert_equal DoorStateMachine, OpenedDoorState.state_machine
      assert_equal WindowStateMachine, OpenedWindowState.state_machine

      Object.send(:remove_const, :WindowStateMachine)
      Object.send(:remove_const, :OpenedWindowState)
    end

    it 'defines the state machine only once' do
      class WindowStateMachine < Aquam::Machine; end

      OpenedDoorState.use_machine DoorStateMachine
      OpenedDoorState.use_machine WindowStateMachine

      assert_equal DoorStateMachine, OpenedDoorState.state_machine

      Object.send(:remove_const, :WindowStateMachine)
    end

    it 'defines all the events as methods' do
      OpenedDoorState.use_machine DoorStateMachine

      assert OpenedDoorState.instance_methods.include? :open
      assert OpenedDoorState.instance_methods.include? :close
      assert OpenedDoorState.instance_methods.include? :knock
    end

    it 'fails by default on every event method' do
      OpenedDoorState.use_machine DoorStateMachine

      assert_raises Aquam::InvalidTransitionError do
        OpenedDoorState.new(nil).open
      end

      assert_raises Aquam::InvalidTransitionError do
        OpenedDoorState.new(nil).close
      end

      assert_raises Aquam::InvalidTransitionError do
        OpenedDoorState.new(nil).knock
      end
    end
  end

  describe 'state_machine instance method' do
    it 'returns the state machine class defined' do
      OpenedDoorState.use_machine DoorStateMachine

      assert_equal DoorStateMachine, OpenedDoorState.new(nil).state_machine
    end

    it 'fails if the state machine was not defined' do
      assert_raises Aquam::InvalidStateMachineError do
        OpenedDoorState.new(nil).state_machine
      end
    end
  end
end
