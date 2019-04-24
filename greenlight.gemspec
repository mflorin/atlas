Gem::Specification.new do |s|
  s.name          = 'greenlight'
  s.version       = '0.0.1-alpha'
  s.date          = '2019-04-24'
  s.summary       = 'Automated Tests Language for APIs'
  s.description   = 'A Ruby DSL to help writing automated tests for APIs.'
  s.authors       = ['Florin Mihalache']
  s.email         = 'florin.mihalache@gmail.com'
  s.add_runtime_dependency 'typhoeus', '~> 1.1'
  s.files         = %w[lib/greenlight.rb lib/greenlight/console.rb lib/greenlight/injector.rb lib/greenlight/request.rb lib/greenlight/scenario.rb lib/greenlight/test.rb]
  s.homepage      = 'http://github.com/mflorin/greenlight'
  s.license       = 'MIT'
 
end
