require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

class HTTPStubServer < WEBrick::HTTPServer

  attr_reader :servlet

  def initialize(port)
    options = { :Port => port, :DoNotListen => true, :BindAddress => nil, :ServerName => nil, :ServerAlias => nil }
    options.merge!(:AccessLog => []) if HTTPStub.disable_logging?
    super options
    @servlet = HTTPStubServlet.get_instance self, port
  end

  def hier
    puts "hier"
  end

  def service(req, res)
    @servlet.service(req, res)
  end

end
