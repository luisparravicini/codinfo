class Server
  attr_reader :port

  def initialize(ip, port)
    @ip = ip
    @port = port
  end

  def ip
    @ip.bytes.to_a.join(".")
  end

  def self.unpack(data)
    ip = data[0, 4]
    port = data[4, 2].unpack('n').first

    Server.new(ip, port)
  end
end

