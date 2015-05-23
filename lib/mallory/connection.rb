require 'eventmachine'
require 'em-http-request'
require 'redis'

module Mallory
  class Connection < EM::Connection
    def initialize(request_builder, proxy_builder, logger, certificate_manager)
      @logger = logger
      @request_builder = request_builder
      @proxy_builder = proxy_builder
      @certificate_manager = certificate_manager
      @start = Time.now
      @secure = false
      @proto = 'http'
      @data = ''
    end

    def ssl_handshake_completed # EM::Connection
      @logger.debug 'Secure connection intercepted'
      @secure = true
    end

    def post_init # EM::Connection
      @logger.debug "Start connection #{object_id}"
    end

    def unbind(reason = nil) # EM::Connection
      @logger.debug "Close connection #{object_id} #{reason}"
    end

    def error
      @logger.info "Failure in #{Time.now - @start}s"
      send_data "HTTP/1.1 500 Internal Server Error\nContent-Type: text/html\nConnection: close\n\n"
      close_connection_after_writing
    end

    def receive_data(chunk) # EM::Connection
      @data << chunk
      begin
        request = @request_builder.build(@data)
      rescue WEBrick::HTTPStatus::BadRequest
        # not a complete request yet
        return
      rescue => e
        puts "error: #{e}, #{e.backtrace}"
        return
      else
        @data = ''
      end
      if !@secure && request.method.eql?('connect')
        # TEMPORARY FIXME
        cc = @certificate_manager.get(request.host)
        ca = File.read('./keys/ca.crt')
        private_key_file = Tempfile.new('private_key_file')
        private_key_file.write (cc.key)
        private_key_file.close
        cert_chain_file = Tempfile.new('cert_chain_file')
        cert_chain_file.write (cc.cert + ca)
        cert_chain_file.close
        send_data "HTTP/1.0 200 Connection established\r\n\r\n"
        start_tls private_key_file: private_key_file.path, cert_chain_file: cert_chain_file.path
        true
      else
        proxy = @proxy_builder.build
        proxy.callback do
          send_data proxy.response
          close_connection_after_writing
        end
        proxy.errback do
          error
        end
        request.protocol = 'https' if @secure
        proxy.perform(request)
      end
    end
  end
end
