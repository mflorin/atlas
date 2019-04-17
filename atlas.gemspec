Gem::Specification.new do |s|
  s.name          = 'atlas'
  s.version       = '0.0.1-alpha'
  s.date          = '2019-04-17'
  s.summary       = 'Automated Tests Language for APIs'
  s.description   = 'A Ruby DSL to help writing automated tests for APIs.'
  s.authors       = ['Florin Mihalache']
  s.email         = 'florin.mihalache@gmail.com'
  s.add_runtime_dependency 'typhoeus', '~> 1.1'
  s.files         = %w[lib/atlas.rb lib/atlas/console.rb lib/atlas/injector.rb lib/atlas/library.rb lib/atlas/request.rb lib/atlas/scenario.rb lib/atlas/test.rb]
  s.homepage      = 'http://github.com/mflorin/atlas'
  s.license       = 'MIT'
 
end
