# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bitmask-attribute}
  s.version = "1.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bruce Williams", "Joel Moss"]
  s.date = %q{2011-01-14}
  s.email = %q{bruce@codefluency.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    "Gemfile",
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "bitmask-attribute.gemspec",
    "init.rb",
    "lib/bitmask-attribute.rb",
    "lib/bitmask_attribute.rb",
    "lib/bitmask_attribute/definition.rb",
    "lib/bitmask_attribute/value_proxy.rb",
    "test/test_bitmask_attribute.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://codaset.com/joelmoss/bitmask-attribute}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails3 compatibile bitmask attribute support for ActiveRecord}
  s.test_files = [
    "test/test_bitmask_attribute.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.0.3"])
      s.add_runtime_dependency(%q<shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.0.3"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.0.3"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
  end
end

