require 'webrick'

module Mallory
  class Request

    attr_accessor :protocol

    def initialize(data, logger)
      @logger = logger
      line = data.match(/([A-Z]{3,8})\s(?:(http\w*):\/\/)*(?:(\w*):*(\d{2,5})*)(\/{0,1}.*)\sHTTP/)
      method = line[1]
      @protocol = "http"
      host = line[3] || data.match(/Host:\s(.*)\n/)[1]
      port = line[4]
      path = line[5]
      data.sub!("#{method} #{line[3]}:#{port}", "#{method} #{line[3]}/")
      data.sub!("Host: #{line[3]}:#{port}", "Host: #{line[3]}")
      @request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
      @request.parse(StringIO.new(data))
      @body = @request.body
    rescue WEBrick::HTTPStatus::LengthRequired
      @body = nil
    rescue WEBrick::HTTPStatus::BadRequest
      raise
    end

    def uri
      @request.request_uri.tap { |u| u.scheme = protocol }.to_s
    end

    def host
      @request['host'].split(":")[0]
    end

    def method
      @request.request_method.downcase
    end

    def headers
      headers = {}
      @request.each { |head| headers[head] = @request[head] }
      headers
    end

    def body
      @body
    end

  end
end
