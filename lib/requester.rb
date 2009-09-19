require 'socket'

class UDPRequester
  attr_accessor :socket_class
  attr_accessor :capture_response

  def initialize
    @socket_class = UDPSocket
  end

  #TODO refactor with request_many

  def request(msg, host, port)
    socket = @socket_class.send(:new)
    begin
      socket.send(msg, 0, host, port)
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

  def request_many(msg, host, port)
    socket = @socket_class.send(:new)
    begin
      socket.send(msg, 0, host, port)
      received = quit = false
      while !quit do 
        unless select([socket], nil, nil, TIMEOUT)
          if received
            quit = true
            next
          else
            raise "timeout waiting for #{host}:#{port} data"
          end
        end

        received = true
        resp = socket.recvfrom(65536)
        write_packet(resp.first) if capture_response

        yield(resp, socket)
      end
    ensure
      socket.close
    end
  end

  def write_packet(resp)
    File.open('responses', 'a') do |f|
      f.write([resp.size].pack('n'))
      f.write(resp)
    end
  end

end
