require 'eventmachine'
require 'em-http-request'

module Mallory
  class Proxy
    MAX_ATTEMPTS = 10

    include EventMachine::Deferrable

    def initialize(ct, it, response_builder, logger, certificate_authority)
      @connect_timeout = ct
      @inactivity_timeout = it
      @response_builder = response_builder
      @logger = logger
      @certificate_authority = certificate_authority
      @retries = 0
      @response = ''
      @start = Time.now
    end

    def perform(request)
      @method = request.method.to_s.downcase
      @uri = request.uri
      @request_headers = request.headers
      @body = request.body || ''
      submit
    end

    def send_data(data)
      @response << data
    end

    attr_reader :response

    def options
      options = {
        connect_timeout: @connect_timeout,
        inactivity_timeout: @inactivity_timeout
      }
      options
    end

    def submit
      @retries += 1
      if @retries > MAX_ATTEMPTS
        fail
        return
      end
      @logger.debug "Attempt #{@retries} - #{@method.upcase} #{@uri}"
      request_params = { head: @request_headers, decoding: false }
      request_params.update(body: @body) if %w(post put).include?(@method)
      http = EventMachine::HttpRequest.new(@uri, options).send(@method, request_params)
      http.errback do
        @logger.debug "Attempt #{@retries} - Failed"
        submit
      end
      http.callback do
        @logger.debug "Attempt #{@retries} - Success"
        response = @response_builder.build(http)
        @logger.request response.body
        send_data "HTTP/1.1 #{response.status} #{response.description}\n"
        send_data response.headers
        send_data "\r\n\r\n"
        send_data response.body
        @logger.debug "Send content #{response.body.length} bytes"
        @logger.info "Success (#{Time.now - @start}s, #{@retries} attempts)"
        succeed
      end
    end
  end
end
