module Mallory
  class Cert

    def initialize domain
      csr = CertificateAuthority::SigningRequest.new
      dn = CertificateAuthority::DistinguishedName.new
      dn.common_name = "localhost"
      csr.distinguished_name = dn
      k = CertificateAuthority::MemoryKeyMaterial.new
      k.generate_key(2048)
      csr.key_material = k
      csr.digest = "SHA256"
      csr.to_x509_csr.to_pem
    end

  end
end
