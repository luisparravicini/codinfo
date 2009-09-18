TIMEOUT = 3

class CODInfo
  PROLOG = "\xff\xff\xff\xff"

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
      data = expect_response(data, "getserversResponse")

      data = data.split(/\\/)
      # TODO why?
      raise "error!?" unless data[0] == "\0"
      raise "no EOT" unless data.last == 'EOT'
      data[1..-2].map do |x|
        if x.size != 6
          puts "x.size != 6"
          next
        end

        Server.unpack(x)
      end.compact
      #TODO check the final EOT
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

    UDPRequester.request(msg, host, port) do |resp, socket|
      yield(resp, socket)
    end
  end

  def write_packet(resp)
    File.open('responses', 'a') do |f|
      f.write([resp.size].pack('n'))
      f.write(resp)
    end
  end

end

