module EventMachine
  module Mallory
    class Response

      def initialize http
        @logger = EventMachine::Mallory::Logger.instance
        @http = http
      end

      def status
        @http.response_header.status
      end

      def description
        @http.response_header.http_reason
      end

      def body
        @http.response
      end

      def headers
        headers = []
        @http.response_header.each do |header| 
          next if header[0].match(/^X_|^VARY|^VIA|^SERVER|^TRANSFER_ENCODING|^CONNECTION/)
          header_name = "#{header[0].downcase.capitalize.gsub('_','-')}"
          case header[1]
          when Array
            header[1].each do |header_value|
              headers << "#{header_name}: #{header_value}"
            end
          when String
            headers << "#{header_name}: #{header[1]}"
          end
        end
        headers << "Connection: close"
        return headers.join("\n")
      end
    end
  end
end
