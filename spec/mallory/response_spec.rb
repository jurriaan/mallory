require 'spec_helper'
require 'thin'
require 'em-http-request'
require 'mallory/response'
require 'responder'

describe EventMachine::Mallory::Response do

  before(:all) do
    Thread.new { EM.run  }
    trap(:INT) { EM.stop }
    trap(:TERM){ EM.stop }
    web = Thin::Server.new(Responder, '127.0.0.1', 6701)
    web.silent = true
    web.start
    sleep 5
    p web.running?
  end

  after(:all) do
    EM.stop
  end

  it "should 1" do
    options = {}
    http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200", options).get
    http.callback {
      p "SUCCESS"
      p http.response_header.status
      p http.response_header
      p http.response
    }
    http.errback {
      p "ERRBACK"
      p http.error
    }
  end

  it "should 2" do
  end
end
