$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
    gem.name            = "ljapi"
    gem.platform        = Gem::Platform::RUBY
    gem.files             = `git ls-files`.split("\n")  
    gem.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")  
    gem.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }  
    gem.require_paths   = ["lib"]
    gem.authors         = ['Mighty']
    gem.summary         = 'API for accessing and working with LiveJournal'
    gem.version         = '0.0.3'
    gem.description     = "%q{LiveJournal XML-RPC API}"
end
