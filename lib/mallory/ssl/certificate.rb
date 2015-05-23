module Mallory
  module SSL
    class Certificate
      def initialize(key, cert)
        @key = key
        @cert = cert
      end

      def self.csr(domain)
        key = OpenSSL::PKey::RSA.new 1024
        csr = OpenSSL::X509::Request.new
        csr.version = 0
        csr.subject = OpenSSL::X509::Name.parse "/CN=#{domain}"
        csr.public_key = key.public_key
        signed = csr.sign key, OpenSSL::Digest::SHA1.new
        [key, signed]
      end

      def cert
        @cert.to_pem
      end

      def key
        @key.to_pem
      end
    end
  end
end
