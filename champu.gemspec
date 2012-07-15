$:.unshift(File.dirname(__FILE__) + '/lib')
require 'champu/version'

Gem::Specification.new do |s|
  s.name = "champu"
  s.version = Champu::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true 
  s.summary = "A simple orchestration/workflow dsl on top of knife ssh"
  s.description = s.summary
  s.author = "Ranjib  Dey"
  s.email = "dey.ranjib@gmail.com"
  s.homepage = "https://github.com/ranjibd/champu"
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc Rakefile ) + Dir.glob("{lib,spec}/**/*")
end

