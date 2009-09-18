
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
    resp = read_first_packet

    list = info.parse_serversResponse([resp[2..-1]])
    list.each do |server|
      server.ip.should_not be_nil
      #TODO what else should be tested?
    end
  end

  it "should parse first server" do
    info = CODInfo.new
    resp = read_first_packet

    list = info.parse_serversResponse([resp[2..-1]])
    server = list.first

    server.ip.should == "87.106.29.59"
    server.port.should == 28951
  end

  it "should parse last server" do
    info = CODInfo.new
    resp = read_first_packet

    list = info.parse_serversResponse([resp[2..-1]])
    server = list.last

    server.ip.should == "193.47.83.181"
    server.port.should == 28930
  end

  def read_first_packet
    read_packet('servers.first_packet')
  end

  def read_packet(name)
    fname = File.join(File.dirname(__FILE__), name)
    IO.read(fname)
  end
end
