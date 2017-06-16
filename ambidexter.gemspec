Gem::Specification.new do |s|
  s.name        = 'ambidexter'
  s.version     = '0.0.7'
  s.executables << 'ambidexter'
  s.date        = '2016-06-12'
  s.summary     = 'Gem for testing network for HTML stuff'
  s.description = 'Ambidexter hands two hands and will give bouth to help you in testing your network for HTTP stuff'
  s.authors     = ['Oleg Cherednichenko']
  s.email       = 'olegh.cherednichenko@gmail.com'
  s.files       = ['lib/server.rb',
                   'lib/client.rb',
                   'lib/application.rb',
                   'bin/ambidexter',
                   'files/file.txt',
                   'files/image.jpeg']
  s.homepage    = 'http://rubygems.org/gems/ambidexter'
  s.license     = 'MIT'
  s.add_dependency 'curb', '~> 0.9.3'
  s.add_dependency 'colorize', '~> 0.8.1'
  s.add_dependency 'usagewatch', '~>0.0.7'
end
