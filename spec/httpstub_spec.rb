require "net/http"
require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

describe HTTPStub do

  before :each do
    HTTPStub.listen_on([3000, 3001])
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
    HTTPStub.listen_on([3000, 3001])
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
