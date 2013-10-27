require 'spec_helper'
require 'mallory/ssl/certificate_manager'

describe Mallory::SSL::CertificateManager do

  before(:each) do 
    @domain = "domain.com"
    @cs = double("certificate_storage")
    expect(@cs).to receive(:get).with(@domain).and_return(nil)
    expect(@cs).to receive(:put)
    @cf = double("certificate_factory")
    expect(@cf).to receive(:get).with(@domain).and_return("CERT")
  end

  it "Gets a new cert" do
    cf = Mallory::SSL::CertificateManager.new(@cs, @cf)
    cf.get(@domain).should eq("CERT")
  end

  it "Gets the same cert" do
    expect(@cs).to receive(:get).with(@domain).and_return("CERT")
    cf = Mallory::SSL::CertificateManager.new(@cs, @cf)
    cf.get(@domain).should eq("CERT")
    cf.get(@domain).should eq("CERT")
  end

end
