#!/usr/bin/ruby

#
# Script to get information on cod4 servers.
#
# It's not usable right now!
#
# By Luis Parravicini <lparravi@gmail.com>
#

require 'socket'


#
# parece que es casi igual al protocolo del Q3
#

TIMEOUT = 3
PROLOG = "\xff\xff\xff\xff"

host = ARGV.shift
port = ARGV.shift


# players info
#cmd = "getstatus"

def expect_response(resp, msg)
  cmd, data = resp.first.split("\n", 2)

  raise "invalid response header" unless cmd[0, 4] == PROLOG
  resp_msg = cmd[4..-1]
  unless resp_msg.chomp == msg
    raise "invalid response (#{msg} != #{resp_msg})"
  end

  data
end

def parse_infoResponse(data)
  data = expect_response(data, "infoResponse")

  server = Hash.new
  data.split("\\")[1..-1].each_slice(2) { |x| server[x.first] = x.last }

  sep = "\t|\t"
  puts [ server['clients'], '/',
    server['sv_maxclients'], sep, server['mapname'], sep,
    server['gametype'], sep, server['hostname']
  ].join
end

msg = "#{PROLOG}#{cmd}"

socket = UDPSocket.new
socket.send(msg, 0, host, port)
resp = socket.recvfrom(65536) if select([socket], nil, nil, TIMEOUT)

module CODInfo
  def self.get_info(host, port=28960)
    #TODO what is the xxx? sending 'getinfo' also works. but the 'xxx' is
    # what the game sends.
    cmd = "getinfo xxx"
    CODInfo.request(cmd, host, port) do |resp, _|
      unless resp.nil?
      #p resp
        parse_infoResponse(resp)
      end
    end
  end

  # the default ip is queried by the game to refresh the server list
  def self.get_servers(host='63.146.124.21', port=20810)
    # TODO 6 ?
    cmd = "getservers 6 full empty"
    #TODO need to read all the responses, not just the first
    CODInfo.request(cmd, host, port) do |resp, _|
      unless resp.nil?
      #p resp
        data = expect_response(resp, "getserversResponse")
        p data[0, 6]
        p data[0, 6].split(//).map { |x| x[0] }
        p data.size
        #EOT
      end
    end
  end

  private

  def self.request(cmd, host, port)
    msg = "#{PROLOG}#{cmd}"

    socket = UDPSocket.new
    socket.send(msg, 0, host, port)
    resp = socket.recvfrom(65536) if select([socket], nil, nil, TIMEOUT)

    yield(resp, socket)

    socket.close
  end

end


#CODInfo.get_info(host, port)
CODInfo.get_servers(host, port)
