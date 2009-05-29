require 'webrick'
require File.expand_path(File.dirname(__FILE__) + "/webrick_monkey_patch")
require File.expand_path(File.dirname(__FILE__) + "/httpstubservlet")
require File.expand_path(File.dirname(__FILE__) + "/httpstubserver")

class HTTPStub

  @@root_server = nil
  @@thread = nil

  def self.listen_on(ports)
    stop_server

    unless @@root_server
      @@root_server = WEBrick::HTTPServer.new :Port => 10000, :DoNotListen => true
      [ports].flatten.each do |port|
        @@root_server.virtual_host HTTPStubServer.new(port)
        @@root_server.listen "0.0.0.0", port
      end
      @@thread = Thread.new(@@root_server) { |server| server.start }
    end
  end

  def self.initialize_server(port)
    @@root_server.server_for_port(port)
  end

  def self.stop_server
    if @@thread
      @@root_server.virtual_hosts.each { |h| h.servlet.clear_responses }
      @@root_server.shutdown
      @@thread.join
      @@thread = nil
      @@root_server = nil
    end
  end


  def self.get(url, metadata, body)
    stub(:get, url, metadata, body)
  end

  def self.post(url, metadata, body)
    stub(:post, url, metadata, body)
  end

  def self.put(url, metadata, body)
    stub(:put, url, metadata, body)
  end

  def self.delete(url, metadata, body)
    stub(:delete, url, metadata, body)
  end


  def self.stub(method, url, metadata, body)
    parsed_url = URI.parse(url)
    server = initialize_server parsed_url.port
    path = if parsed_url.query.nil? or parsed_url.query == ""
             parsed_url.path
           else
             "#{parsed_url.path}?#{parsed_url.query}"
           end
    server.servlet.send("stub_#{method}", path, metadata, body)
  end

end
