require 'spec_helper'
require 'em-mitm-proxy'
options = {:listen => 6701}
EventMachine::MitmProxy.new(options).start!
