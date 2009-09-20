TIMEOUT = 3

class CODInfo
  PROLOG = "\xff\xff\xff\xff"

  attr_accessor :requester

  def initialize
    @requester = UDPRequester.new
  end

  def get_info(host, port=nil)
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

  def get_status(host, port=nil)
    port ||= 28960
    cmd = "getstatus"
    request(cmd, host, port) do |resp, _|
      break if resp.nil?
      parse_statusResponse(resp)
    end
  end

  # the default ip is queried by the game to refresh the server list
  def get_servers(host=nil, port=nil)
    host ||= '63.146.124.21'
    port ||= 20810
    # TODO 6 ?
    cmd = "getservers 6 full empty"
    servers = []
    #TODO need to read all the responses, not just the first
    request_many(cmd, host, port) do |resp, _|
      break if resp.nil?
      servers += parse_serversResponse(resp)
    end

    servers
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

      # TODO what for is this \x0?
      raise "error!?" unless data[0] == 0
      raise "no EOT" unless data[-4..-1] == '\\EOT'

      data = data[1..-5]
      raise "invalid data length (#{x.size})" if data.size % 7 != 0
      result = []
      data.bytes.to_a.each_slice(7) do |elem|
        raise "invalid server prefix (#{elem.first})" unless elem.first == 92
        result << Server.unpack(elem[1..-1])
      end

      result
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

  #TODO refactor with request_many
  def request(cmd, host, port)
    msg = "#{PROLOG}#{cmd}"

    @requester.request(msg, host, port) do |resp, socket|
      yield(resp, socket)
    end
  end

  def request_many(cmd, host, port)
    msg = "#{PROLOG}#{cmd}"

    @requester.request_many(msg, host, port) do |resp, socket|
      yield(resp, socket)
    end
  end

end

