require 'spec_helper'
require 'mallory/ssl/ca'
require 'mallory/ssl/certificate'

describe Mallory::SSL::CA do

  let(:domain) { "example.com" }

  before(:each) do 
    @crt = <<eos
-----BEGIN CERTIFICATE-----
MIIBrjCCAWqgAwIBAgIJAI9Jet0z2WxsMA0GCSqGSIb3DQEBBQUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMTMxMDI3MDkzODI4WhcNMTQxMDI3MDkzODI4WjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMEkwDQYJKoZIhvcNAQEBBQADOAAwNQIuATk8
6gLLDreN38mrzriz9YG7M+mac0+y+aIP1K8tdZ8YvUKMzlzeC4eKnD4FzwIDAQAB
o1AwTjAdBgNVHQ4EFgQU9WaQgAp6p34/notUvUlRK/dUlA8wHwYDVR0jBBgwFoAU
9WaQgAp6p34/notUvUlRK/dUlA8wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQUF
AAMvAAAfhV/bVru7TPf16ip7Q0vBYX1imJJXZV72aTOmHXuQ06wbYQ0zkBmxyNe/
jTQ=
-----END CERTIFICATE-----
eos
    @key = <<eos
-----BEGIN RSA PRIVATE KEY-----
MIHkAgEAAi4BOTzqAssOt43fyavOuLP1gbsz6ZpzT7L5og/Ury11nxi9QozOXN4L
h4qcPgXPAgMBAAECLgCCtONlJPxQJbhzO+j388gHSWmBGfzx/guAg7RljGrPI1Ml
0ZFD03gWr4oLNqkCFxmupXAH1DbNXgAj7XZ4qr4dG8uBzvNtAhcMMloyUncI47Ov
WT6Th8Fzkv+LT3ecqwIXCI9H/o3tchKCuQNAexL+vXyQLgTmyAUCFmJJYpIj+xyn
2Fo31Q8N8ORstObwffcCFxlbbXtpwyj9lQcnH0hgQka0iyO2oe5P
-----END RSA PRIVATE KEY-----
eos
    @dir = Dir.mktmpdir
    @crt_file = "#{@dir}/test.crt"
    @key_file = "#{@dir}/test.key"
    File.open(@crt_file, 'w') { |file| file.write(@crt) }
    File.open(@key_file, 'w') { |file| file.write(@key) }
  end

  after(:each) do
    FileUtils.remove_entry_secure @dir
  end

  it "Reads a cert from a file" do
    Mallory::SSL::CA.new(@crt_file, @key_file).to_pem.should eq(@crt)
  end

  it "Signs a given csr" do
    key, csr = Mallory::SSL::Certificate.csr(domain)
    ca = Mallory::SSL::CA.new(@crt_file, @key_file)
    cert = ca.sign(csr)
    cert.subject.should eq(OpenSSL::X509::Name.parse "/CN=nobody/DC=#{domain}")
    Mallory::SSL::Certificate.new(key, cert).cert
  end

end
