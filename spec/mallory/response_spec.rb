require 'spec_helper'
require 'em-http-request'
require 'mallory/response'
require 'responder'

describe EventMachine::Mallory::Response do

  it "should 1" do
    EM.run do
      http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200", {}).get
      http.callback do
        p "SUCCESS"
        EM.stop
      end
      http.errback { EM.stop; raise }
    end
  end

  it "should 2" do
    EM.run do
      http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200", {}).get
      http.callback do
        p "SUCCESS"
        EM.stop
      end
      http.errback { EM.stop; raise }
    end
  end
end
