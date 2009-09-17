#!/usr/bin/ruby

#
# Script to get information on cod4 servers.
#
#
# By Luis Parravicini <lparravi@gmail.com>
#

require 'socket'


TIMEOUT = 3
PROLOG = "\xff\xff\xff\xff"


class CODInfo
  attr_accessor :capture_response

  def get_info(host, port=28960)
    port ||= 28960
    #TODO what is the xxx? sending 'getinfo' also works. but the 'xxx' is
    # what the game sends.
    cmd = "getinfo xxx"
    request(cmd, host, port) do |resp, _|
      break if resp.nil?
      #p resp
      server = parse_infoResponse(resp)

      sep = "\t|\t"
      puts [ server['clients'] || 0, '/',
        server['sv_maxclients'], sep, server['mapname'], sep,
        server['gametype'], sep, server['hostname']
      ].join
    end
  end

  def get_status(host, port=28960)
    port ||= 28960
    cmd = "getstatus"
    request(cmd, host, port) do |resp, _|
      break if resp.nil?
      server = parse_statusResponse(resp)

      p server
    end
  end

  # the default ip is queried by the game to refresh the server list
  def get_servers(host='63.146.124.21', port=20810)
    host ||= '63.146.124.21'
    port ||= 20810
    # TODO 6 ?
    cmd = "getservers 6 full empty"
    #TODO need to read all the responses, not just the first
    request(cmd, host, port) do |resp, _|
      break if resp.nil?
      server = parse_serversResponse(resp)
    end
  end

#  private

  def expect_response(resp, msg)
    cmd, data = resp.first.split("\n", 2)

    raise "invalid response header" unless cmd[0, 4] == PROLOG
    resp_msg = cmd[4..-1]
    unless resp_msg.chomp == msg
      raise "invalid response (#{msg} != #{resp_msg})"
    end

    data
  end

  def parse_serversResponse(data)
      #p resp
      data = expect_response(data, "getserversResponse")
      p data[0, 6]
      p data[0, 6].split(//).map { |x| x[0] }
      p data.size
      #EOT
      data
  end

  def parse_infoResponse(data)
    data = expect_response(data, "infoResponse")

    server = Hash.new
    data.split("\\")[1..-1].each_slice(2) { |x| server[x.first] = x.last }

    server
  end

  def parse_statusResponse(data)
    data = expect_response(data, "statusResponse")

    server = Hash.new
    data.split("\\")[1..-1].each_slice(2) { |x| server[x.first] = x.last }

    server
  end


  def request(cmd, host, port)
    msg = "#{PROLOG}#{cmd}"

    socket = UDPSocket.new
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

  def write_packet(resp)
    File.open('responses', 'a') do |f|
      f.write([resp.size].pack('n'))
      f.write(resp)
    end
  end

end


if __FILE__ == $0
  host = ARGV.shift
  port = ARGV.shift

  raise "usage: #{$0} <host> [port]" if host.nil?

  info = CODInfo.new
#  info.capture_response = true
  info.get_info(host, port)
#  info.get_status(host, port)
#  info.get_servers(host, port)
end
