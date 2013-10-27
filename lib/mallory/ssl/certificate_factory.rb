module Mallory
  module SSL
    class CertificateFactory

      def initialize ca
        @ca = ca
      end

      def get domain
        key, csr = Mallory::SSL::Certificate.csr(domain)
        signed = @ca.sign(csr)
        Mallory::SSL::Certificate.new(key, signed)
      end
  
    end
  end
end
