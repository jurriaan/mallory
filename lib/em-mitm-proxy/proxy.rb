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
          if http.response_header.status > 400
            @logger.debug "#{http.response_header.status} > 400"
            resubmit
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
            @logger.report "Success (#{Time.now-Time.now}s, #{@retries} attempts)"
          end
          self.succeed
        }
      rescue
      end
    end
  end
end
