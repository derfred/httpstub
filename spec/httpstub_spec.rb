require "net/http"
require 'net/https'
require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

describe HTTPStub do

  before :each do
    HTTPStub.listen_on(["http://localhost:3000/", "http://localhost:3001/"])
  end

  after :each do
    HTTPStub.stop_server
  end

  it "should run server in a new thread" do
    HTTPStub.get "http://localhost:3000/", { :content_type => "text/plain" }, "test"
    lambda do
      timeout(1) do
        Net::HTTP.get_response(URI.parse("http://localhost:3000/"))
      end
    end.should_not raise_error
  end

  it "should stop server" do
    HTTPStub.get "http://localhost:3000/", { :content_type => "text/plain" }, "test"
    HTTPStub.stop_server
    lambda do
      timeout(1) do
        Net::HTTP.get_response(URI.parse("http://localhost:3000/"))
      end
    end.should raise_error(Errno::ECONNREFUSED)
  end

  it "should listen on multiple ports" do
    HTTPStub.get "http://localhost:3000/", { :content_type => "text/plain" }, "3000"
    HTTPStub.get "http://localhost:3001/", { :content_type => "text/plain" }, "3001"

    timeout(1) do
      Net::HTTP.get_response(URI.parse("http://localhost:3001/"))
      Net::HTTP.get_response(URI.parse("http://localhost:3000/"))
    end
  end

  it "should allow calling listen_on multiple times" do
    HTTPStub.listen_on(["http://localhost:3000/", "http://localhost:3001/"])
  end

  it "should stub GET request" do
    HTTPStub.get "http://localhost:3000/port_number", { :content_type => "text/plain" }, "port_number"
    HTTPStub.get "http://localhost:3000/port_number?query_port", { :content_type => "text/plain" }, "port"
    HTTPStub.get "http://localhost:3000/port_number?query_host", { :content_type => "text/plain" }, "host"
    timeout(1) do
      Net::HTTP.get_response(URI.parse("http://localhost:3000/port_number")).body.should == "port_number"
      Net::HTTP.get_response(URI.parse("http://localhost:3000/port_number?query_port")).body.should == "port"
      Net::HTTP.get_response(URI.parse("http://localhost:3000/port_number?query_host")).body.should == "host"
    end
  end

end

describe HTTPStub, "SSL stubs" do

  before :each do
    HTTPStub.listen_on(["https://localhost:3002"])
  end

  after :each do
    HTTPStub.stop_server
  end

  it "should stub SSL requests" do
    HTTPStub.get "https://localhost:3002/port_number", { :content_type => "text/plain" }, "port_number"
    timeout(1) do
      http = Net::HTTP.new('localhost', 3002)
      http.use_ssl = true
      http.start do |http|
        http.request(Net::HTTP::Get.new('/port_number')).body.should == "port_number"
      end
    end
  end

end
