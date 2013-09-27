module EventMachine
  module Mallory
    class Logger
      TIME_FORMAT = "%F %T.%L"

      attr_accessor :verbose

      def self.instance
        @@instance ||= new
      end

      def debug msg
        report msg if @verbose
      end

      def report msg
        puts "#{Time.now.strftime(TIME_FORMAT)} - ##{@id}: #{msg}"
      end
    end
  end
end
