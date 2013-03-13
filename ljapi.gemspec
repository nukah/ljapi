# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ljapi"
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nukah"]
  s.date = "2013-03-13"
  s.description = ""
  s.email = "flow.energy@gmail.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/ljapi.rb",
    "lib/ljapi/base.rb",
    "lib/ljapi/login.rb",
    "lib/ljapi/models.rb",
    "lib/ljapi/models/journal.rb",
    "lib/ljapi/models/post.rb",
    "lib/ljapi/models/user.rb",
    "lib/ljapi/post.rb",
    "lib/ljapi/request.rb",
    "lib/ljapi/utils.rb",
    "ljapi.gemspec",
    "spec/api_spec.rb",
    "spec/perfomance_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/nukah/ljapi"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "LiveJournal Remote API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<jeweler>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord-tableless>, ["~> 1.0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<sanitize>, [">= 0"])
      s.add_development_dependency(%q<ruby-prof>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<activerecord-tableless>, ["~> 1.0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<sanitize>, [">= 0"])
      s.add_dependency(%q<ruby-prof>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<activerecord-tableless>, ["~> 1.0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<sanitize>, [">= 0"])
    s.add_dependency(%q<ruby-prof>, [">= 0"])
  end
end

