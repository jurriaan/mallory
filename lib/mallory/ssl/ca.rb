#!/usr/bin/env ruby
module Mallory
  module SSL
    class CA
      def initialize crt, key
        @crt = OpenSSL::X509::Certificate.new(File.read(crt))
        @key = OpenSSL::PKey::RSA.new(File.read(key))
      end

      def to_pem
        @crt.to_pem
      end

      def sign csr
        cert = OpenSSL::X509::Certificate.new
        cert.serial = 0
        cert.version = 2
        cert.not_before = Time.now
        cert.not_after = Time.now + 365*24*3600
        cert.subject = csr.subject
        cert.public_key = csr.public_key
        cert.issuer = @crt.subject

        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = @crt
        ef.create_extension 'basicConstraints', 'CA:FALSE'
        ef.create_extension 'keyUsage', 'keyEncipherment,dataEncipherment,digitalSignature'
        ef.create_extension 'subjectKeyIdentifier', 'hash'

        cert.sign @key, OpenSSL::Digest::SHA1.new
      end

    end
  end
end
