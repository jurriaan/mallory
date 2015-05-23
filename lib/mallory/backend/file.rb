module Mallory
  module Backend
    class File
      # It would be cool to add signal trap to refresh proxy list when file contents change
      # (with initial validation, so if file is malformed, old list stays)
      def initialize(filename)
        @proxies = []
        begin
          lines = ::File.readlines(filename)
          fail if lines.nil?
          fail if lines.empty?
        rescue
          raise('Proxy file missing or empty')
        end
        lines.each do |line|
          if line.strip.match(/.*:\d{2,6}/)
            @proxies << line.strip
          else fail('Wrong format') end
        end
      end

      def any
        @proxies.sample
      end

      def all
        @proxies
      end
    end
  end
end
