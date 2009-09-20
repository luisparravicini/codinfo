class CODTools
  def initialize(cod_info=nil)
    @cod_info = CODInfo.new
  end

  def all_statuses
    @cod_info.get_servers.each do |server|
      p server
      p @cod_info.get_status(server.ip, server.port)
    end
  end
end
