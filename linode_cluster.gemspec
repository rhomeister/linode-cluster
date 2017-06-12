# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'linode_cluster/version'

Gem::Specification.new do |spec|
  spec.name          = "linode_cluster"
  spec.version       = LinodeCluster::VERSION
  spec.authors       = ["Ruben Stranders"]
  spec.email         = ["r.stranders@gmail.com"]

  spec.summary       = %q{A simple wrapper library for creating a cluster of Linodes.}
  spec.homepage      = "https://github.com/rhomeister/linode-cluster"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'linode', '~> 0.9'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
