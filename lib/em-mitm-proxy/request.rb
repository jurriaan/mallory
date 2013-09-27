require 'webrick'

module Mitm
  class Request

    attr_accessor :proto
    def initialize data
      line = data.match(/([A-Z]{3,8})\s(?:(http[\w+]*):\/\/(\w*):*(\d{2,5})*)*(\/{0,1}.*)\sHTTP/)
      method = line[1]
      @protocol = line[2]
      port = line[4] 
      path = line[5]
      host = line[3] || data.match(/Host:\s(.*)\n/)[1]
      data.sub!("http://#{host}","")
      @request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
      @request.parse(StringIO.new(data))
    rescue WEBrick::HTTPStatus::BadRequest
      raise
    end

    def uri
      "#{@protocol}://#{@request['host']}#{@request.path}"
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
      @request.body
    rescue WEBrick::HTTPStatus::LengthRequired
      nil
    end

  end
end
