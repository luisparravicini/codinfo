$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'codinfo'

describe 'servers command (first response)'  do
  before do
    @info = CODInfo.new
  end

  it "should parse a packet response" do
    resp = read_first_packet
    list = @info.parse_serversResponse([resp[2..-1]])

    list.size.should == 115
  end

  it "should parse each server port" do
    resp = read_first_packet
    list = @info.parse_serversResponse([resp[2..-1]])

    list.each do |server|
      server.port.should_not be_nil
      server.port.should > 0
      server.port.should < 65535
      #TODO what else should be tested?
    end
  end

  it "should parse each server ip" do
    resp = read_first_packet
    list = @info.parse_serversResponse([resp[2..-1]])

    list.each do |server|
      server.ip.should_not be_nil
      #TODO what else should be tested?
    end
  end

  it "should parse first server" do
    resp = read_first_packet
    list = @info.parse_serversResponse([resp[2..-1]])

    server = list.first

    server.ip.should == "87.106.29.59"
    server.port.should == 28951
  end

  it "should parse last server" do
    resp = read_first_packet
    list = @info.parse_serversResponse([resp[2..-1]])

    server = list.last

    server.ip.should == "193.47.83.181"
    server.port.should == 28930
  end

  def read_first_packet
    read_packet('servers.first_packet')
  end

  def read_packet(name)
    fname = File.join(File.dirname(__FILE__), 'data', name)
    IO.read(fname)
  end
end
