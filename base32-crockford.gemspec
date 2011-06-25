$:.push File.expand_path("../lib", __FILE__)
require 'base32/crockford'

spec = Gem::Specification.new do |s|
  s.name = 'base32-crockford'
  s.version = Base32::Crockford::VERSION
  s.summary = "32-symbol notation for expressing numbers in a form that can be conveniently and accurately transmitted between humans"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_path = 'lib'
  s.author = "Levin Alexander"
  s.homepage = "http://levinalex.net/src/base32"
  s.email = "mail@levinalex.net"

  s.add_development_dependency 'rake'
end
