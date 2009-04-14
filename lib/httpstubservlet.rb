class HTTPStubServlet < WEBrick::HTTPServlet::AbstractServlet

  @@instances = {}
  def self.get_instance(server, port)
    @@instances[port] ||= self.new(server)
  end

  def initialize(server)
    super
    clear_responses
  end

  [:get, :post, :put, :delete].each do |method|
    define_method "stub_#{method}" do |url, headers, body|
      @responses[url] ||= {}
      @responses[url][method] = [headers, body]
    end

    define_method "do_#{method.to_s.upcase}" do |request, response|
      if canned_response = get_response(request.unparsed_uri, method)
        fill_response(response, canned_response)
      else
        respond_with_404(response)
      end
    end
  end


  def clear_responses
    @responses = {}
  end

  def get_response(path, method)
    (@responses[path] || {})[method]
  end

  def fill_response(response, canned_response)
    headers = canned_response.first || {}
    headers.each do |k, v|
      next if k == :status
      response[convert_header_name(k)] = v
    end

    response.status = headers[:status] || 200
    response.body = canned_response.last
  end

  def respond_with_404(response)
    response.status = 404
    response.body = "not found"
  end

  def convert_header_name(key)
    {
      :content_type => "Content-Type"
    }[key] || key
  end

end
