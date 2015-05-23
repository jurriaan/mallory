require 'spec_helper'
require 'em-http-request'
require 'mallory/response'
require 'responder'

describe Mallory::Response do
  let(:logger) { Logger.new(STDOUT) }

  it 'should filter out headers' do
    EM.run do
      http = EventMachine::HttpRequest.new('http://127.0.0.1:6701/200/headers', {}).get
      http.callback do
        r = Mallory::Response.new(http, logger)
        r.description.should eq('OK')
        r.status.should eq(200)
        r.body.should eq('OK')
        r.headers.split("\n").reject { |h| h.match(/^Date/) }.join("\n").should eq("Content-type: text/html;charset=utf-8\nContent-length: 2\nSet-cookie: cookie1=JohnDoe; domain=127.0.0.1; path=/; HttpOnly\nSet-cookie: cookie2=JaneRoe; domain=127.0.0.1; path=/; HttpOnly\nConnection: close")
        EM.stop
      end
      http.errback { EM.stop; fail }
    end
  end
end
