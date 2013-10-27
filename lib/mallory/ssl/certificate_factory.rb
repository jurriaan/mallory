module Mallory
  module SSL
    class CertificateFactory

      def initialize ca
        @ca = ca
      end

      def get domain
        csr = Mallory::SSL::Certificate.csr(domain)
        signed = @ca.sign(csr)
        Mallory::SSL::Certificate.new(signed)
      end
  
    end
  end
end
