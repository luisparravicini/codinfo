
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'info'

describe CODInfo do
  it "should parse correct number of servers in 'servers' response" do
    info = CODInfo.new
    fname = File.join(File.dirname(__FILE__), 'servers.first_packet')
    resp = IO.read(fname)

    list = info.parse_serversResponse([resp[2..-1]])
    list.size.should == 115
  end

  it "should parse correctly each server port in 'servers' command" do
    info = CODInfo.new
    fname = File.join(File.dirname(__FILE__), 'servers.first_packet')
    resp = IO.read(fname)

    list = info.parse_serversResponse([resp[2..-1]])
    list.each do |server|
      server.port.should_not be_nil
      server.port.should > 0
      server.port.should < 65535
      #TODO what else should be tested?
    end
  end

  it "should parse correctly each server ip in 'servers' command" do
    info = CODInfo.new
    fname = File.join(File.dirname(__FILE__), 'servers.first_packet')
    resp = IO.read(fname)

    list = info.parse_serversResponse([resp[2..-1]])
    list.each do |server|
      server.ip.should_not be_nil
      #TODO what else should be tested?
    end
  end
end
