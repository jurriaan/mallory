module EventMachine
  module Mallory
    class Logger
      TIME_FORMAT = "%F %T.%L"

      attr_accessor :verbose

      def self.instance
        @@instance ||= new
      end

      def debug msg
        info msg if @verbose
      end

      def info msg
        puts "#{Time.now.strftime(TIME_FORMAT)} - #{msg}"
      end
    end
  end
end
