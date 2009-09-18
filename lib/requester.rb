require 'socket'

module UDPRequester
  def self.request(msg, host, port)
    socket = UDPSocket.new
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
