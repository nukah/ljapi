require 'rake'
Gem::Specifications.new do |gem|
    gem.name            = "Live Journal XML-RPC API"
    gem.files           = FileList['lib/**/*.rb']
    gem.platform        = Gem::Platform::CURRENT
    gem.require_path    = '.'
    gem.summary         = 'API for accessing and working with LiveJournal'
    gem.version         = '0.0.1'
    gem.add_runtime_dependency  'sanitized'
end
