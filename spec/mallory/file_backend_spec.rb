require 'spec_helper'
require 'mallory/backend/file'

describe Mallory::Backend::File do
  let(:proxies) { ['127.0.0.1:5600', '127.0.0.1:5601', '127.0.0.1:5602'] }

  it 'should return all proxies' do
    file = File.should_receive(:readlines).with('proxies.txt').and_return(proxies)
    Mallory::Backend::File.new('proxies.txt').all.should eq(proxies)
  end

  it 'should return one proxy' do
    File.should_receive(:readlines).with('proxies.txt').and_return([proxies.first])
    Mallory::Backend::File.new('proxies.txt').any.should eq(proxies.first)
  end

  it 'should raise on empty file' do
    File.should_receive(:readlines).with('proxies.txt')
    expect { Mallory::Backend::File.new('proxies.txt') }.to raise_error('Proxy file missing or empty')
  end

  it 'should raise on wrong format' do
    File.should_receive(:readlines).with('proxies.txt').and_return(['wr0ng:f0rm4t'])
    expect { Mallory::Backend::File.new('proxies.txt') }.to raise_error('Wrong format')
  end

  it 'should raise on missing file' do
    File.should_receive(:readlines).with('proxies.txt').and_raise(Errno::ENOENT)
    expect { Mallory::Backend::File.new('proxies.txt') }.to raise_error('Proxy file missing or empty')
  end
end
