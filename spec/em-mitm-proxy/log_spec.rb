require 'spec_helper'
require 'em-mitm-proxy/logger'

describe Mitm::Logger do
  let(:logger) {Mitm::Logger.instance}

  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end

  it "creates logger singleton" do
    logger1 = Mitm::Logger.instance
    logger2 = Mitm::Logger.instance
    expect(logger1).to be(logger2)
  end

  it "logs" do
    out = capture_stdout do
      logger.report "Some text"
    end
    expect(out.string).to match(/.*Some text/)
  end
end