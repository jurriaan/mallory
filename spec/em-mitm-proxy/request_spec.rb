require 'spec_helper'
require 'mallory/request'

describe "Mallory::Request" do

  methods = ['GET', 'POST', 'HEAD', 'PUT', 'CONNECT', 'DELETE']

  good_requests = [
    {:path => "/", :host => "localhost"},
    {:path => "/index.html", :host => "localhost"},
    {:path => "/index.html?test", :host => "localhost:80"},
    {:path => "http://localhost/index.html", :host => "localhost"},
    {:path => "http://localhost/", :host => "localhost"},
    {:path => "https://localhost/", :host => "localhost:443"}
  ]

  bad_requests = [
    {:path => "http://loca lhost :6700", :host => "localhost:6700"}
    #{:path => "http://localhost:6700/", :host => "localhost:6700"},
    #{:path => "http://localhost:6700/index.html", :host => "localhost"}
  ]

  good_requests.each do |request|
    it "should accept #{request[:path]}" do
      methods.each do |method|
        body =<<-HTTP.gsub(/^ +/, '')
          #{method} #{request[:path]} HTTP/1.1
          Host: #{request[:host]}
        HTTP
        rq = Mallory::Request.new(body)
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
        expect { Mallory::Request.new(body) }.to raise_error
      end
    end
  end

end
