require 'webrick'
require 'eventmachine'
require 'em-http-request'
require 'redis'

module Mitm
  class Connection < EM::Connection
    def initialize(ct, it, verbose, backend)
      @logger = Mitm::Logger.instance
      @verbose = verbose
      @connect_timeout = ct
      @inactivity_timeout = it
      @id = SecureRandom.hex[0, 6]
      @start = Time.now
      @secure = false
      @proto = "http"
      @retries = 0
      @backend = backend
    end

    def throw_error
      @logger.debug "Failure in #{Time.now-@start}s (#{@retries} attempts)"
      send_data "HTTP/1.1 500 Internal Server Error\nContent-Type: text/html\nConnection: close\n\n"
      close_connection_after_writing
    end

    def try_proxy(method, uri, request_headers, body = '')
      @retries+=1
      proxy = @backend.any
      @logger.debug "Attempt #{@retries} - #{method.upcase} #{uri} via #{proxy}"
      if @retries > 10
        throw_error 
        return false
      end
      options = {
        :connect_timeout => @connect_timeout,
        :inactivity_timeout => @inactivity_timeout,
        :proxy => {
        :host => proxy.split(':')[0],
        :port => proxy.split(':')[1]
      }
      }
      if [:post, :put].include?(method) 
        request_params = {:head => request_headers, :body => body}
      else
        request_params = {:head => request_headers}
      end
      begin
        http = EventMachine::HttpRequest.new(uri, options).get request_params
        http.errback { 
          @logger.debug "Attempt #{@retries} - Failed"
          try_proxy(method, uri, request_headers, body)
        }
        http.callback {
          @logger.debug "Attempt #{@retries} - Success"
          if http.response_header.status > 400
            @logger.debug "#{http.response_header.status} > 400"
            try_proxy(method, uri, request_headers, body) 
          else
            send_data "HTTP/1.1 #{http.response_header.status} #{http.response_header.http_reason}\n"
            headers = []
            begin
              http.response_header.each do |hh| 
                hname = "#{hh[0].downcase.capitalize.gsub('_','-')}"
                if hh[1].instance_of?(Array)
                  hh[1].each do |xx|
                    headers << "#{hname}: #{xx}"
                  end
                elsif hh[1].instance_of?(Array)
                  headers << "#{xx}: #{hh[1]}"
                end
              end
              headers.delete("Connection: keep-alive")
              headers.delete("Transfer-encoding: chunked")
              headers.select { |r| /^X-|^Vary|^Via|^Server/ =~ r }.each {|r| headers.delete(r)}
              headers << "Content-Length: #{http.response.length}"
            rescue

            end
            headers << "Connection: close"
            send_data headers.join("\n")
            send_data "\r\n\r\n"
            @logger.debug "Send content #{http.response.length} bytes"
            send_data http.response
            close_connection_after_writing
            @logger.report "Success (#{Time.now-@start}s, #{@retries} attempts)"
          end
        }
      rescue
      end
    end

    def ssl_handshake_completed
      @logger.debug "Secure connection intercepted"
      @secure = true
    end

    def post_init
      @logger.debug "Start connection"
    end

    def unbind(reason=nil)
      @logger.debug "Close connection #{reason}"
    end

    def parse data
      begin
        host = data.match(/Host:\s(.*)\r/)[1]
        proto = data.match(/[A-Z]{3,8}\s(http[\d+])/)[1] rescue "http"
        data.sub!("http://#{host}","")
        req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
        req.parse(StringIO.new(data))
        request_headers = {}
        req.each { |head| request_headers[head] = req[head] }
      rescue => e
        @logger.debug e.message
        throw_error
      else
        {:request => req, :headers => request_headers}
      end
    end

    def receive_data(data)
      rr = parse data
      req = rr[:request]
      request_headers = rr[:headers]
      if not @secure and req.request_method.downcase.eql?('connect')
        send_data "HTTP/1.0 200 Connection established\r\n\r\n"
        start_tls :private_key_file => './keys/server.key', :cert_chain_file => './keys/server.crt', :verify_peer => false
        return true
      end
      @proto = 'https' if @secure
      try_proxy(req.request_method.downcase.to_s, "#{@proto}://#{req['host']}#{req.path}", request_headers, req.body)
    end

  end
end
