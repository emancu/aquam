# aquam
[![Gem Version](https://badge.fury.io/rb/aquam.png)](http://badge.fury.io/rb/aquam)
[![Build Status](https://travis-ci.org/emancu/aquam.svg)](https://travis-ci.org/emancu/aquam)
[![Code Climate](https://codeclimate.com/github/emancu/aquam/badges/gpa.svg)](https://codeclimate.com/github/emancu/aquam)
[![Dependency Status](https://gemnasium.com/emancu/aquam.svg)](https://gemnasium.com/emancu/aquam)

A Ruby DSL for writing Finite State Machines and validate its transitions'

## Dependencies

`aquam` requires Ruby 2.1.x or later. No more dependencies.

## Installation

    $ gem install aquam

# Getting started

`aquam` helps you to define _Finite State Machines_ with a very simple DSL which
also will validate events, states and the transition between them.

First of all, you must know that a State Machine should be a different object,
where you specify the valid states and the transitions fired by the events.

That being said, lets take a look how it works.

## Machine

Basically a Machine consists on

- states
- events
- transitions

There are three key words in our DSL that will help you to write your
own Finite State Machine, plus the `attribute` method.

### Example

```ruby
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
```

> NOTE: `OpenedDoorState` and `ClosedDoorState` definitions are missing but
> we will cover States definition later.

### state

A `state` maps a symbol to a State class.
It tells to the _machine_ it is a valid state and which class represents it.

```ruby
state :opened, OpenedDoorState
```

### event

An `event` is a method which triggers the transition from one _state_ to another.
Each _state object_ must define **only** the events that are specified here.

```ruby
event :open do
  ...
end
```

### transition

A `transition` moves the _state machine_ from **state A** to **state B**.
It can only be defined inside an `event` and you can define multiple transitions.

```ruby
transition from: :a_valid_state, to: :other_valid_state
```

### attribute

The `attribute` holds the name of the accessor in your own class where
the state name (string or symbol) will be stored.

By default uses `:state` as method accessor.

```ruby
attribute :state
```

### Extra

Being a subclass of `Aquam::Machine` also gives you some helpful **class methods**:

| Class Method | Description                                      | Example (ruby)                  |
|:-------------|:-------------------------------------------------|:--------------------------------|
| states       | `Hash` Valid states mapped to a class            | `{ opened: OpenedDoorState }`   |
| events       | `Hash` Valid events with all its transitions     | `{ open: { closed: :opened } }` |
| valid_state? | `Boolean` Check if it is a valid state           | `true`                          |
| valid_event? | `Boolean` Check if it is a valid event           | `true`                          |

And for **instance methods** it defines:

| Class Method      | Description                              | Example (ruby)                |
|:------------------|:-----------------------------------------|:------------------------------|
| current_state     | `Aquam::State` Instance of current state | `#<ClosedDoorState:0x007...>` |
| trigger           | `Aquam::State` Instance of the new state | `#<ClosedDoorState:0x008...>` |
| valid_state?      | `Boolean` Check if it is a valid state   | `true`                        |
| valid_event?      | `Boolean` Check if it is a valid event   | `true`                        |
| valid_transition? | `Boolean` Check if it is a valid event   | `true`                        |


## State

For each state, we define a class that implements the corresponding _events_.
Every bit of behavior that is *state-dependent* should become a method in the class.
`aquam` uses metaprogramming to define methods for every single event listed
in the state machine used.

### Example

```ruby
class OpenedDoorState < Aquam::State
  use_machine DoorStateMachine

  def close
    # Do something

    @object.state = :closed
  end
end

class ClosedDoorState < Aquam::State
  use_machine DoorStateMachine

  def open
    # Do something

    @object.state = :opened
  end
end
```

### use_machine

This is the only method that you **must** call from every State class,
in order to define the interface according to the _state machine_.
Basically, it defines a method for every event defined in the _state machine_.

```ruby
use_machine DoorStateMachine
```
> NOTE: You can not change its value and it is accessible from all subclasses.
