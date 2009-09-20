#!/usr/bin/ruby

#
# Script to get information on cod4 servers.
#
#
# By Luis Parravicini <lparravi@gmail.com>
#

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'codinfo'


host = ARGV.shift
port = ARGV.shift

raise "usage: #{$0} <host> [port]" if host.nil?

info = CODInfo.new
#  info.requester.capture_response = true
#  server = info.get_status(host, port)
#  servers = info.get_servers
server = info.get_info(host, port)

sep = "\t|\t"
puts [ server['clients'] || 0, '/',
        server['sv_maxclients'], sep, server['mapname'], sep,
        server['gametype'], sep, server['hostname']
].join
