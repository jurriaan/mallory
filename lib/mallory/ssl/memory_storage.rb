module Mallory
  module SSL
    class MemoryStorage

      def initialize ca
        @ca = ca
        @sn = 12
        @storage = {}
      end

      def get domain
        if @storage[domain]
          return @storage[domain]
        else
          cert = sign(domain)
          @storage[domain] = cert
          return cert
        end
      end

      def sign domain
        csr = Mallory::SSL::Certificate.csr(domain)
        signed = @ca.sign(csr)
        Mallory::SSL::Certificate.new(signed)
      end

    end
  end
end
