Gem::Specification.new do |s|
  s.name        = 'gist_nuke'
  s.version     = '0.0.1'
  s.date        = '2013-09-09'
  s.summary     = 'Batch deletion of gists'
  s.description = 'A great way to clean up your github gist profile'
  s.authors     = ["zachgersh", "joeyschoblaska"]
  s.email       = 'zachgersh@gmail.com'
  s.files       = ["lib/gist_nuke.rb"]
  s.homepage    = 'http://zachgersh.github.io'
  s.license     = 'MIT'
  s.add_runtime_dependency "typhoeus", "~> 0.6.5"
  s.add_development_dependency "vcr", "~> 2.5.0"
end
