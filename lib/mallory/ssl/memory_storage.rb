module Mallory
  module SSL
    class MemoryStorage

      def initialize
        @certs = {}
      end

      def get domain
        @certs[domain]
      end

      def put cert
        domain = cert.subject.to_a.select{|x|x[0]=="CN"}.first[1] #OpenSSL::X509::Name could have hash interface. Could.
        @certs[domain] = cert
      end

    end
  end
end
