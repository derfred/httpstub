require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

class HTTPStubServer < WEBrick::HTTPServer

  attr_reader :servlet

  def initialize(port, use_ssl)
    options = { :Port => port, :BindAddress => nil, :ServerName => nil, :ServerAlias => nil }
    options.merge!(:AccessLog => [], :Logger => WEBrick::BasicLog.new([])) if HTTPStub.disable_logging?
    options.merge!(ssl_options) if use_ssl
    super options
    @servlet = HTTPStubServlet.get_instance self, port
  end

  def service(req, res)
    @servlet.service(req, res)
  end

  private
    def ssl_options
      {
        :SSLEnable       => true,
        :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertName     => [ [ "CN", "localhost" ] ]
      }
    end

end
