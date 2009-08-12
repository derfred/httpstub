require 'webrick'
require 'webrick/https'
require File.expand_path(File.dirname(__FILE__) + "/webrick_monkey_patch")
require File.expand_path(File.dirname(__FILE__) + "/httpstubservlet")
require File.expand_path(File.dirname(__FILE__) + "/httpstubserver")

class HTTPStub

  @@server_list = {}
  @@thread_group = nil
  @@disable_logging = true

  def self.disable_logging=(value)
    @@disable_logging = value
  end

  def self.disable_logging?
    @@disable_logging
  end


  def self.listen_on(urls)
    clear_responses if @@thread_group

    unless @@thread_group
      @@thread_group = ThreadGroup.new
      [urls].flatten.each do |url|
        @@thread_group.add build_server(url)
      end
    end
  end

  def self.build_server(url)
    uri = URI.parse(url)
    server = HTTPStubServer.new(uri.port, uri.scheme == "https")
    @@server_list[uri.port] = server

    Thread.start do
      server.start
    end
  end

  def self.stop_server
    if @@thread_group
      @@server_list.values.each do |server|
        server.servlet.clear_responses
        server.shutdown
      end

      @@thread_group.list.each { |th| th.join }
      @@thread_group = nil
      @@server_list.clear
    end
  end

  def self.clear_responses
    @@server_list.values.each do |server|
      server.servlet.clear_responses
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
    server = @@server_list[parsed_url.port]
    path = if parsed_url.query.nil? or parsed_url.query == ""
             parsed_url.path
           else
             "#{parsed_url.path}?#{parsed_url.query}"
           end
    server.servlet.send("stub_#{method}", path, metadata, body)
  end

end
