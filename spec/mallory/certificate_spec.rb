require 'spec_helper'
require 'mallory/ssl/certificate'

describe Mallory::SSL::Certificate do

  it "Generates a csr" do
    Mallory::SSL::Certificate.csr("example.com")[1].to_s.should match /^-----BEGIN CERTIFICATE REQUEST.*END CERTIFICATE REQUEST-----$/m
  end

end
