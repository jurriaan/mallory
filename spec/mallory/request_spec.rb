require 'spec_helper'
require 'mallory/request'

describe Mallory::Request do
  let(:logger) { Logger.new(STDOUT) }

  methods = ['GET', 'POST', 'HEAD', 'PUT', 'CONNECT', 'DELETE']

  good_requests = [
    {:path => "/", :host => "localhost"},
    {:path => "/index.html", :host => "localhost"},
    {:path => "/index.html?test", :host => "localhost:80"},
    {:path => "http://localhost/index.html", :host => "localhost"},
    {:path => "http://localhost/", :host => "localhost"},
    {:path => "https://localhost/", :host => "localhost:443"},
    {:path => "localhost:443", :host => "localhost:443"},
    {:path => "/login", :host => "localhost"},
    {:path => "localhost:443/index.html", :host => "localhost:443"}
  ]

  bad_requests = [
    {:path => "http://loca lhost :6700", :host => "localhost:6700"}
  ]

  good_requests.each do |request|
    it "should accept #{request[:path]}" do
      methods.each do |method|
        body =<<-HTTP.gsub(/^ +/, '')
          #{method} #{request[:path]} HTTP/1.1
          Host: #{request[:host]}
        HTTP
        rq = Mallory::Request.new(body, logger)
        rq.method.should eq(method.downcase)
        rq.body.should be(nil)
      end
    end
  end

  bad_requests.each do |request|
    it "should raise on #{request[:path]}" do
      methods.each do |method|
        body =<<-HTTP.gsub(/^ +/, '')
          #{method} #{request[:path]} HTTP/1.1
          Host: #{request[:host]}
        HTTP
        expect { Mallory::Request.new(body, logger) }.to raise_error
      end
    end
  end

end
