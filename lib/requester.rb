require 'socket'

class UDPRequester
  attr_accessor :socket_class
  attr_accessor :capture_response

  def initialize
    @socket_class = UDPSocket
  end

  def request(msg, host, port)
    socket = @socket_class.new
    begin
      socket.send(msg, 0, host, port)
      #TODO loop
      unless select([socket], nil, nil, TIMEOUT)
        raise "timeout waiting for #{host}:#{port} data"
      end

      resp = socket.recvfrom(65536)
      write_packet(resp.first) if capture_response

      yield(resp, socket)
    ensure
      socket.close
    end
  end
end
