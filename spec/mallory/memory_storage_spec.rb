require 'spec_helper'
require 'mallory/ssl/memory_storage'

describe Mallory::SSL::MemoryStorage do
  let(:domain) { 'example.com' }
  let(:name) { OpenSSL::X509::Name.parse "/DC=unknown/CN=#{domain}" }
  let(:cert) do
    cert = OpenSSL::X509::Certificate.new
    cert.subject = name
    cert
  end

  it 'Put a cert' do
    Mallory::SSL::MemoryStorage.new.put(cert)
  end

  it 'Get a cert' do
    ms = Mallory::SSL::MemoryStorage.new
    ms.put(cert)
    ms.get(domain).should eq(ms.get(domain))
  end
end
