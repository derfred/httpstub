require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

class HTTPStubServer < WEBrick::HTTPServer

  attr_reader :servlet

  def initialize(port)
    super :Port => port, :DoNotListen => true, :BindAddress => nil, :ServerName => nil, :ServerAlias => nil
    @servlet = HTTPStubServlet.get_instance self, port
  end

  def hier
    puts "hier"
  end

  def service(req, res)
    @servlet.service(req, res)
  end

end
