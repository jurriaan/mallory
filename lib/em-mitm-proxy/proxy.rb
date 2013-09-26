require 'eventmachine'
require 'em-http-request'

module Mitm
  class Proxy

    include EventMachine::Deferrable

    def initialize(backend)
      @retries = 0
      @logger = Mitm::Logger.instance
      @backend = backend
      @response = ''
    end

    def resubmit
      @proxy = @backend.any
      submit
    end

    def perform request
      @method = request.method.to_s
      @uri = request.uri
      @request_headers = request.headers
      @body = request.body || ''
      resubmit
    end

    def send_data data
      @response << data
    end

    def response
      @response
    end

    def submit
      @retries+=1
      @logger.debug "Attempt #{@retries} - #{@method.upcase} #{@uri} via #{@proxy}"
      if @retries > 10
        self.fail
      end
      options = {
        :connect_timeout => @connect_timeout,
        :inactivity_timeout => @inactivity_timeout,
        :proxy => {
        :host => @proxy.split(':')[0],
        :port => @proxy.split(':')[1]
      }
      }
      if [:post, :put].include?(@method) 
        request_params = {:head => @headers, :body => @body}
      else
        request_params = {:head => @headers}
      end
      begin
        http = EventMachine::HttpRequest.new(@uri, options).get request_params
        http.errback { 
          @logger.debug "Attempt #{@retries} - Failed"
          resubmit
        }
        http.callback {
          @logger.debug "Attempt #{@retries} - Success"
          response = Response.new(http)
          if response.status > 400
            @logger.debug "#{response.status} > 400"
            resubmit
          else
            send_data "HTTP/1.1 #{response.status} #{response.description}\n"
            send_data response.headers
            send_data "\r\n\r\n"
            send_data response.body
            @logger.debug "Send content #{response.body.length} bytes"
            @logger.report "Success (#{Time.now-Time.now}s, #{@retries} attempts)"
          end
          self.succeed
        }
      rescue
      end
    end
  end
end
