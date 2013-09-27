require 'spec_helper'
require 'mallory'
options = {:listen => 6701}
EventMachine::Mallory.new(options).start!
