#!/usr/bin/ruby

#
# Script to get information on cod4 servers.
#
# It's not usable right now!
#
# by lparravi@gmail.com

require 'socket'


#
# parece que es casi igual al protocolo del Q3
#

TIMEOUT = 3
PROLOG = "\xff\xff\xff\xff"

host = ARGV.shift
port = ARGV.shift || 28960


# devuelve info, igual a getinfo, pero esto es lo snifeado
#cmd = "getinfo xxx"
# igual que el anterio
#cmd = "getinfo"

# devuelve info de jugadores
#cmd = "getstatus"

# cuando refresca la lista del "master game server"
# ahora solo leo 1 paquete pero en lo snifeado, hay muchos paquetes
# de respuesta (es una lista de ~18k servidores)
host = "63.146.124.21"
port = 20810
# el 6 creo que son las opciones de filtrado
cmd = "getservers 6 full empty"

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

unless resp.nil?
#p resp
#  parse_infoResponse(resp)
  data = expect_response(resp, "getserversResponse")
p data[0, 4]
p data[0, 4].split(//).map { |x| x[0] }
p data.size
end

socket.close
