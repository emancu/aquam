require 'aquam'

class DoorState < Aquam::State; end

class OpenedDoorState < DoorState
  def close
    @object.state = :closed
  end
end

class ClosedDoorState < DoorState
  def open
    @object.state = :opened
  end
end

class DoorStateMachine < Aquam::Machine
  state :opened, OpenedDoorState
  state :closed, ClosedDoorState

  event :open do
    transition from: :closed, to: :opened
  end

  event :close do
    transition from: :opened, to: :closed
  end

  event :knock do
    transition from: :opened, to: :opened
    transition from: :closed, to: :closed
  end
end

class Door
  attr_accessor :state
  attr_reader :machine

  def initialize
    @state = :closed
    @machine = DoorStateMachine.new self
  end
end
