$:.push File.expand_path("../lib", __FILE__)
version = `git describe --abbrev=0 | awk -F'-g[0-9a-fA-F]+' '{print $1}'`

Gem::Specification.new do |gem|
    gem.name            = "ljapi"
    gem.platform        = Gem::Platform::RUBY
    gem.files             = `git ls-files`.split("\n")  
    gem.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")  
    gem.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }  
    gem.require_paths   = [".","lib"]
    gem.authors         = ['Mighty']
    gem.summary         = 'API for accessing and working with LiveJournal'
    gem.version         = 0.3
    gem.description     = "%q{LiveJournal XML-RPC API}"

    gem.add_dependency('dalli', '>= 2.3.0')
end
