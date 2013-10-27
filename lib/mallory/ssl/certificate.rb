module Mallory
  module SSL
    class Certificate

      def initialize cert
        @cert = cert
      end

      def self.csr domain
        key = OpenSSL::PKey::RSA.new 1024
        csr = OpenSSL::X509::Request.new
        csr.version = 0
        csr.subject = OpenSSL::X509::Name.parse "CN=nobody/DC=#{domain}"
        csr.public_key = key.public_key
        csr.sign key, OpenSSL::Digest::SHA1.new
      end

      def to_pem
        @cert.to_pem
      end

    end
  end
end
