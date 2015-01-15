require_relative 'helper'
require_relative 'door_state_machine'

describe Aquam::MachineClassMethods do
  describe 'attribute' do
    it 'uses :state as default' do
      assert_equal :state, DoorStateMachine.attribute
    end

    it 'defines the proper attribute to access the state name' do
      class NewStateMachine < Aquam::Machine
        attribute :state_name
      end

      assert_equal :state_name, NewStateMachine.attribute

      Object.send(:remove_const, :NewStateMachine)
    end
  end

  describe 'states' do
    it 'returns a hash with all the states as keys' do
      assert_equal [:opened, :closed], DoorStateMachine.states.keys
    end

    it 'returns a hash with all the states defined' do
      assert_equal OpenedDoorState, DoorStateMachine.states[:opened]
      assert_equal ClosedDoorState, DoorStateMachine.states[:closed]
    end

    it 'checks if it is a valid state' do
      assert DoorStateMachine.valid_state? :opened
      deny DoorStateMachine.valid_state? :not_a_valid_state
    end
  end

  describe 'events' do
    it 'returns a hash with the events as keys' do
      assert_equal [:open, :close, :knock], DoorStateMachine.events.keys
    end

    it 'returns a hash with the transitions of each event' do
      close = { opened: :closed }
      open =  { closed: :opened }
      knock = { opened: :opened, closed: :closed }

      assert_equal close, DoorStateMachine.events[:close]
      assert_equal open,  DoorStateMachine.events[:open]
      assert_equal knock, DoorStateMachine.events[:knock]
    end

    it 'checks if it is a valid event' do
      assert DoorStateMachine.valid_event? :open
      deny DoorStateMachine.valid_event? :not_a_valid_event
    end
  end

  describe 'state' do
    before do
      class AState < Aquam::State; end
      class StateMachine < Aquam::Machine; end
    end

    after do
      Object.send(:remove_const, :AState)
      Object.send(:remove_const, :StateMachine)
    end

    it 'defines a new state into the Machine' do
      assert_equal [], StateMachine.states.keys

      StateMachine.state :a, AState

      assert_equal [:a], StateMachine.states.keys
      assert_equal AState, StateMachine.states[:a]
    end
  end

  describe 'event' do
    before do
      class AState < Aquam::State; end
      class BState < Aquam::State; end

      class StateMachine < Aquam::Machine
        state :a, AState
        state :b, BState
      end
    end

    after do
      Object.send(:remove_const, :AState)
      Object.send(:remove_const, :BState)
      Object.send(:remove_const, :StateMachine)
    end

    it 'defines an event with transitions' do
      assert_equal [], StateMachine.events.keys

      StateMachine.event :toggle do
        transition from: :a, to: :b
        transition from: :b, to: :a
      end

      assert_equal [:toggle], StateMachine.events.keys
    end
  end

  describe 'transition' do
    before do
      class AState < Aquam::State; end
      class BState < Aquam::State; end

      class StateMachine < Aquam::Machine
        state :a, AState
        state :b, BState
      end
    end

    after do
      Object.send(:remove_const, :AState)
      Object.send(:remove_const, :BState)
      Object.send(:remove_const, :StateMachine)
    end

    it 'fails defining a transition between invalid states' do
      assert_raises Aquam::InvalidStateError do
        StateMachine.transition :undefined, :b, :event
      end

      assert_raises Aquam::InvalidStateError do
        StateMachine.transition :a, :undefined, :event
      end
    end

    it 'defines a new transition' do
      assert_equal Hash.new, StateMachine.events[:event]

      StateMachine.transition :a, :b, :event
      expected_transition = { a: :b }

      assert_equal expected_transition, StateMachine.events[:event]
    end
  end
end
