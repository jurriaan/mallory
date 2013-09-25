=begin
BTW, zerknij sobie na klasę Logger w stdlib, można z niej zrobić
singletona w ten sam sposób, żeby trzymać globalnie konfigurację
(jak format stringa, itd.)
=end
module Mitm
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
      puts $stdout, "#{Time.now.strftime(TIME_FORMAT)} - ##{@id}: #{msg}"
    end
  end
end