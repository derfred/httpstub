module WEBrick
  class HTTPServer

    attr_reader :virtual_hosts

    def server_for_port(port)
      @virtual_hosts.find { |s| s[:Port] == port }
    end

  end
end
