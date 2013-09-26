require 'spec_helper'
require 'em-mitm-proxy/backend/file'

describe Mitm::Backend::File do
    
  let(:proxies){ ["127.0.0.1:5600","127.0.0.1:5601", "127.0.0.1:5602"] }

  it "should return all proxies" do
    file=File.should_receive(:readlines).with("proxies.txt")
    proxies.each do |proxy|
      file.and_yield(proxy)
    end
    Mitm::Backend::File.new("proxies.txt").all.should eq(proxies)
  end

  it "should return one proxy" do
    File.should_receive(:readlines).with("proxies.txt").and_yield(proxies.first)
    Mitm::Backend::File.new("proxies.txt").any.should eq(proxies.first)
  end

  it "should raise on empty file" do
    File.should_receive(:readlines).with("proxies.txt")
    expect {Mitm::Backend::File.new("proxies.txt")}.to raise_error("No proxies found")
  end

  it "should raise on wrong format" do
    File.should_receive(:readlines).with("proxies.txt").and_yield("wrong:format")
    expect {Mitm::Backend::File.new("proxies.txt")}.to raise_error("Wrong format")
  end

end
