require File.expand_path(File.dirname(__FILE__) + "/../lib/httpstub")

describe HTTPStubServlet do

  before :each do
    @server = HTTPStubServlet.new mock(:server, :[] => nil)
  end

  [:get, :post, :put, :delete].each do |method|
    it "should respond to a #{method} call" do
      @server.send "stub_#{method}", "/people.xml", { :content_type => "text/html", :status => 200 }, "test"

      req = mock(:request, :unparsed_uri => "/people.xml")
      res = mock(:response)
      res.should_receive(:body=).with("test")
      res.should_receive(:status=).with(200)
      res.should_receive(:[]=).with("Content-Type", "text/html")

      @server.send("do_#{method.to_s.upcase}", req, res)
    end
  end


  it "should default response status to 200" do
    @server.stub_get "/people.xml", { :content_type => "text/html" }, "test"

    req = mock(:request, :unparsed_uri => "/people.xml")
    res = mock(:response, :body= => nil, :[]= => nil)
    res.should_receive(:status=).with(200)

    @server.do_GET(req, res)
  end

  it "should return 404 response if path is not known" do
    req = mock(:request, :unparsed_uri => "/people.xml")
    res = mock(:response)
    res.should_receive(:body=).with("not found")
    res.should_receive(:status=).with(404)

    @server.do_GET(req, res)
  end

  it "should return 404 response if the method for this path is not known " do
    @server.stub_post "/people.xml", { :content_type => "text/html" }, "test"

    req = mock(:request, :unparsed_uri => "/people.xml")
    res = mock(:response)
    res.should_receive(:body=).with("not found")
    res.should_receive(:status=).with(404)

    @server.do_GET(req, res)
  end

end