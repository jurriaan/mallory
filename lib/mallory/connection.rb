require 'eventmachine'
require 'em-http-request'
require 'redis'


module Mallory
  class Connection < EM::Connection
    def initialize(request_builder, proxy_builder, logger)
      @logger = logger
      @request_builder = request_builder
      @proxy_builder = proxy_builder
      @start = Time.now
      @secure = false
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
      @logger.info "Failure in #{Time.now-@start}s"
      send_data "HTTP/1.1 500 Internal Server Error\nContent-Type: text/html\nConnection: close\n\n"
      close_connection_after_writing
    end

    def receive_data(data) # EM::Connection
      begin
      request = @request_builder.build(data)
      rescue
        error
        return
      end
      if not @secure and request.method.eql?('connect')
        send_data "HTTP/1.0 200 Connection established\r\n\r\n"
        start_tls :private_key_file => './keys/server.key', :cert_chain_file => './keys/server.crt', :verify_peer => false
        return true
      end
      proxy = @proxy_builder.build
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