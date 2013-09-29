require 'eventmachine'
require 'em-http-request'

module EventMachine
  module Mallory
    class Proxy
      MAX_ATTEMPTS = 10

      include EventMachine::Deferrable

      def initialize(ct, it, backend, response_builder, logger)
        @connect_timeout = ct
        @inactivity_timeout = it
        @backend = backend
        @response_builder = response_builder
        @logger = logger
        @retries = 0
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

      def options
        {
          :connect_timeout => @connect_timeout,
          :inactivity_timeout => @inactivity_timeout,
          :proxy => {
            :host => @proxy.split(':')[0],
            :port => @proxy.split(':')[1]
          }
        }
      end

      def submit
        @retries+=1
        if @retries > MAX_ATTEMPTS
          fail
          return
        end
        @logger.debug "Attempt #{@retries} - #{@method.upcase} #{@uri} via #{@proxy}"
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
          if response.status > 400
            @logger.debug "#{response.status} > 400"
            resubmit
          else
            send_data "HTTP/1.1 #{response.status} #{response.description}\n"
            send_data response.headers
            send_data "\r\n\r\n"
            send_data response.body
            @logger.debug "Send content #{response.body.length} bytes"
            @logger.info "Success (#{Time.now-Time.now}s, #{@retries} attempts)"
          end
          self.succeed
        }
      end
    end
  end
end
