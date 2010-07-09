# -*- coding: utf-8 -*-

lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "double_trouble/version"

Gem::Specification.new do |s|
  s.name = "double_trouble"
  s.version = DoubleTrouble::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Jakub Kuźma"]
  s.email = "qoobaa@gmail.com"
  s.homepage = "http://github.com/qoobaa/double_trouble"
  s.summary = "Adds nonces to your Rails' forms"
  s.description = "Adds nonces to your Rails' forms"

  s.required_rubygems_version = ">= 1.3.7"

  s.add_dependency "rails", "=2.3.8"
  s.add_development_dependency "test-unit", ">= 2.0"

  s.files = Dir.glob("{lib}/**/*") + %w(LICENSE README.rdoc)
end
