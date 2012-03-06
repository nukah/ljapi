require 'rake'
Gem::Specification.new do |gem|
    gem.name            = "ljapi"
    gem.files           = FileList['lib/**/*.rb']
    gem.platform        = Gem::Platform::CURRENT
    gem.require_path    = '.'
    gem.authors         = ['Mighty']
    gem.summary         = 'API for accessing and working with LiveJournal'
    gem.version         = '0.0.1'
    gem.add_runtime_dependency  'sanitize'
end
