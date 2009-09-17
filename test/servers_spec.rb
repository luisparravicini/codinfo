
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require 'info'

describe CODInfo do
  it "should parse 'servers' command" do
    info = CODInfo.new
    fname = File.join(File.dirname(__FILE__), 'servers.first_packet')
    resp = IO.read(fname)
    info.parse_serversResponse([resp[2..-1]])
  end
end
