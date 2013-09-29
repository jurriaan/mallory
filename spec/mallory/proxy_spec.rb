require 'spec_helper'
require 'mallory/proxy'

describe Mallory::Proxy do

=begin
  it 'should' do
    EM.run do
      http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200", {}).get
      http.callback do
        EM.stop
      end
      http.errback { EM.stop; raise }
    end
  end
=end

end
