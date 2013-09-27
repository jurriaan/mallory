require 'spec_helper'
require 'em-http-request'
require 'mallory/response'
require 'responder'

describe EventMachine::Mallory::Response do

  it "should filter out headers" do
    EM.run do
      http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200/headers", {}).get
      http.callback do
        r = EventMachine::Mallory::Response.new(http)
        r.description.should eq("OK")
        r.status.should eq(200)
        r.body.should eq("OK")
        r.headers.split("\n").reject {|h| h.match(/^Date/)}.join("\n").should eq("Content-type: text/html;charset=utf-8\nContent-length: 2\nSet-cookie: cookie1=JohnDoe; domain=127.0.0.1; path=/; HttpOnly\nSet-cookie: cookie2=JaneRoe; domain=127.0.0.1; path=/; HttpOnly\nConnection: close")
        EM.stop
      end
      http.errback { EM.stop; raise }
    end
  end

  it "should 2" do
    EM.run do
      http = EventMachine::HttpRequest.new("http://127.0.0.1:6701/200", {}).get
      http.callback do
        EM.stop
      end
      http.errback { EM.stop; raise }
    end
  end

end
