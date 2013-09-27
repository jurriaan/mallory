module Mallory
  module Backend
    class File


      def initialize(filename)
        @proxies = []
        ::File.readlines(filename) do |line|
          if line.match(/.*:\d{2,6}/)
            @proxies << line 
          else raise("Wrong format") end
        end
        raise("No proxies found") if @proxies.empty?
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
