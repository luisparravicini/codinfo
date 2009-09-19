$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'codinfo'

describe UDPRequester  do

  it "should send request" do
    req = UDPRequester.new
    req.socket_class = MockRequester

    ip = "1.2.3.4"
    port = 9876
    msg = "hola"
    req.request(msg, ip, port)
  end

end

class MockRequester

  def send(data, flags, host, port)
  end

  def close
  end
end
