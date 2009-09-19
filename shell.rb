#!/usr/bin/ruby

#
# Shell to send command to cod4 servers.
#
#
# By Luis Parravicini <lparravi@gmail.com>
#

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'codinfo'

info = CODInfo.new
quit = false
puts 'COD4 shell'
puts 'type CTRL-D to quit'
while not quit do
  print '> '
  cmd = gets
  break if cmd.nil?
  cmd, *args = cmd.split.map { |x| x.strip }

  p info.send(cmd, *args) 
end
