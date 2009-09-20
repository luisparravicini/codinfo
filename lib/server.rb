class Server
  attr_reader :port

  def initialize(ip, port)
    @ip = ip
    @port = port
  end

  def ip
    @ip.join(".")
  end

  def self.unpack(data)
    ip = data[0, 4]
    port = (data[4] << 8) + data[5]

    Server.new(ip, port)
  end
end

