require 'eventmachine'
require 'em-http-request'

module Mallory
  class Proxy
    MAX_ATTEMPTS = 10

    include EventMachine::Deferrable

    def initialize(ct, it, backend, response_builder, logger, certificate_authority)
      @connect_timeout = ct
      @inactivity_timeout = it
      @backend = backend
      @response_builder = response_builder
      @logger = logger
      @certificate_authority = certificate_authority
      @retries = 0
      @response = ''
      @start = Time.now
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

    def options
      options = {
        :connect_timeout => @connect_timeout,
        :inactivity_timeout => @inactivity_timeout,
      }
      unless @proxy.nil?
        options[:proxy] = {
          :host => @proxy.split(':')[0],
          :port => @proxy.split(':')[1]
        }
      end
      return options
    end

    def submit
      @retries+=1
      if @retries > MAX_ATTEMPTS
        fail
        return
      end
      via = " via #{@proxy}" unless @proxy.nil?
      @logger.debug "Attempt #{@retries} - #{@method.upcase} #{@uri} #{via}"
      if [:post, :put].include?(@method)
        request_params = {:head => @headers, :body => @body}
      else
        request_params = {:head => @headers}
      end
      http = EventMachine::HttpRequest.new(@uri, options).send(@method, request_params)
      http.errback {
        @logger.debug "Attempt #{@retries} - Failed"
        resubmit
      }
      http.callback {
        @logger.debug "Attempt #{@retries} - Success"
        response = @response_builder.build(http)
        @logger.request response.body
        if response.status > 400
          @logger.debug "#{response.status} > 400"
          resubmit
        else
          send_data "HTTP/1.1 #{response.status} #{response.description}\n"
          send_data response.headers
          send_data "\r\n\r\n"
          send_data response.body
          @logger.debug "Send content #{response.body.length} bytes"
          @logger.info "Success (#{Time.now-@start}s, #{@retries} attempts)"
        end
        self.succeed
      }
    end
  end
end
