require 'spec_helper'
require 'mallory/configuration'

describe Mallory::Configuration do
  before(:each) do
    Mallory::Configuration.reset!
  end

  it 'should set logger' do
    logger = 'dummy'
    Mallory::Configuration.logger = logger
    expect(Mallory::Configuration.logger).to be(logger)
  end

  it 'should reset' do
    Mallory::Configuration.logger = 'dummy'
    expect(Mallory::Configuration.logger).to_not be_nil
    Mallory::Configuration.reset!
    expect(Mallory::Configuration.logger).to be_nil
  end
end