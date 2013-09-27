require 'eventmachine'
require 'em-http-request'
require 'redis'

module Mallory
  class Connection < EM::Connection
    def initialize(ct, it, verbose, backend)
      @logger = Mallory::Logger.instance
      @logger.verbose = true if verbose
      @connect_timeout = ct
      @inactivity_timeout = it
      @id = SecureRandom.hex[0, 6]
      @start = Time.now
      @secure = false
      @proto = "http"
      @retries = 0
      @backend = backend
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

    def receive_data(data) # EM::Connection
      request = Mallory::Request.new(data) rescue throw_error
      if not @secure and request.method.eql?('connect')
        send_data "HTTP/1.0 200 Connection established\r\n\r\n"
        start_tls :private_key_file => './keys/server.key', :cert_chain_file => './keys/server.crt', :verify_peer => false
        return true
      end
      request.proto = 'https' if @secure
      proxy = Proxy.new(@backend)
      proxy.callback {
        send_data proxy.response
        close_connection_after_writing
      }
      proxy.errback {
        @logger.debug "Failure in #{Time.now-@start}s (#{@retries} attempts)"
        send_data "HTTP/1.1 500 Internal Server Error\nContent-Type: text/html\nConnection: close\n\n"
        close_connection_after_writing
      }
      proxy.perform(request)
    end
  end
end
