# -*- encoding: utf-8 -*-
require File.expand_path('../lib/activerecord-partitioning/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matthew Denner"]
  gem.email         = ["md12@sanger.ac.uk"]
  gem.description   = %q{Adds support for dumping partitioned tables to db/schema.rb}
  gem.summary       = %q{Very simple dumping of partitioned tables in MySQL}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "activerecord-partitioning"
  gem.require_paths = ["lib"]
  gem.version       = Activerecord::Partitioning::VERSION

  gem.add_dependency "activerecord", "~> 3.2.0"
  gem.add_dependency "activesupport", "~> 3.2.0"

  gem.add_development_dependency "rspec", "~> 2.9.0"
  gem.add_development_dependency "mysql2"
end
