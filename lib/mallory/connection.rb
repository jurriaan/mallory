require 'eventmachine'
require 'em-http-request'
require 'redis'

module EventMachine
  module Mallory
    class Connection < EM::Connection
      def initialize(backend, ct, it)
        @logger = EventMachine::Mallory::Logger.instance
        @connect_timeout = ct
        @inactivity_timeout = it
        @start = Time.now
        @secure = false
        @backend = backend
        @proto = "http"
      end

      def ssl_handshake_completed # EM::Connection
        @logger.debug "Secure connection intercepted"
        @secure = true
      end

      def post_init # EM::Connection
        @logger.debug "Start connection"
      end

      def unbind(reason=nil) # EM::Connection
        @logger.debug "Close connection #{reason}"
      end

      def error
        @logger.report "Failure in #{Time.now-@start}s"
        send_data "HTTP/1.1 500 Internal Server Error\nContent-Type: text/html\nConnection: close\n\n"
        close_connection_after_writing
      end

      def receive_data(data) # EM::Connection
        begin
        request = Mallory::Request.new(data)
        rescue 
          error
          return
        end
        if not @secure and request.method.eql?('connect')
          send_data "HTTP/1.0 200 Connection established\r\n\r\n"
          start_tls :private_key_file => './keys/server.key', :cert_chain_file => './keys/server.crt', :verify_peer => false
          return true
        end
        proxy = Proxy.new(@backend)
        proxy.callback {
          send_data proxy.response
          close_connection_after_writing
        }
        proxy.errback {
          error
        }
        request.protocol = 'https' if @secure
        proxy.perform(request)
      end
    end
  end
end
