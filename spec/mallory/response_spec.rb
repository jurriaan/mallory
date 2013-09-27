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
  end

  after(:all) do
    EM.stop
  end

  it "should 1" do
    options = {}
    http = EventMachine::HttpRequest.new("http://localhost:6701/500", options).get
    http.callback {
      p http.response_header.status
      p http.response_header
      p http.response
    }
  end

  it "should 2" do
  end
end
