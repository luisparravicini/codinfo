#!/usr/bin/ruby

#
# Script to get information on cod4 servers.
#
#
# By Luis Parravicini <lparravi@gmail.com>
#

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'codinfo'



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
