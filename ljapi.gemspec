require 'rake'
Gem::Specification.new do |gem|
    gem.name            = "ljapi"
    gem.files           = FileList['lib/**/*.rb']
    gem.platform        = Gem::Platform::RUBY
    gem.files           = ["lib/ljapi.rb","lib/ljapi/post.rb","lib/ljapi/request.rb", "lib/ljapi/login.rb", "lib/ljapi/user.rb"]
    gem.require_paths   = [%q{lib}]
    gem.authors         = ['Mighty']
    gem.summary         = 'API for accessing and working with LiveJournal'
    gem.version         = '0.0.2'
    gem.add_runtime_dependency  'sanitize'
    gem.description     = "%q{LiveJournal XML-RPC API}"
end
