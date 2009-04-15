Gem::Specification.new do |s|
  s.name = %q{httpstub}
  s.version = "0.1.0.0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Frederik Fix"]
  s.date = %q{2009-04-15}
  s.description = %q{a very simple http server for use in automated integration tests}
  s.email = %q{fred@stemcel.co.uk}
  s.files = ["README", "lib/httpstub.rb", "lib/httpstubservlet.rb", "lib/httpstubserver.rb", "lib/webrick_monkey_patch.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/derfred/httpstub}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{a very simple http server for use in automated integration tests}
end
