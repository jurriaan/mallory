require 'webrick'

module Mitm
  class Request

    attr_accessor :proto
    def initialize data
      @proto = "http"
      begin
        host = data.match(/Host:\s(.*)\r/)[1]
        proto = data.match(/[A-Z]{3,8}\s(http[\d+])/)[1] rescue "http"
        data.sub!("http://#{host}","")
        @request = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
        @request.parse(StringIO.new(data))
      rescue => e
        @logger.debug e.message
        raise
      end
    end

    def uri
      "#{@proto}://#{@request['host']}#{@request.path}"
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
    end

  end
end
