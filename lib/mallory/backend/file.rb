module EventMachine
  module Mallory
    module Backend
      class File

        def initialize(filename)
          @proxies = []
          begin
            lines = ::File.readlines(filename) 
            raise if lines.nil?
          rescue
            raise("Proxy file missing or empty")
          end
          lines.each do |line|
            if line.match(/.*:\d{2,6}/)
              @proxies << line 
            else raise("Wrong format") end
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
end