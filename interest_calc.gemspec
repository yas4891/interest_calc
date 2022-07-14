require_relative 'lib/interest_calc/version'

Gem::Specification.new do |s|
  s.name        = 'interest_calc'
  s.version     = InterestCalc::VERSION
  s.summary     = "Useful methods around calculating interests, especially for open lines of credit"
  s.description = "Helps you calculate interest for open lines of credit"
  s.authors     = ["Christoph Engelhardt"]
  s.email       = 'christoph@christophengelhardt.com'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  s.homepage    = 'https://rubygems.org/gems/interest_calc'
  s.license     = 'MIT'

  s.add_dependency('active_support', '~> 7.0.0')
  s.add_development_dependency('minitest', '~> 5.16')

  #s.add_dependency('interest_days', '~> 0.4.1')

end
