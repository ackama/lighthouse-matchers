# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lighthouse/matchers/version'

Gem::Specification.new do |spec|
  spec.name          = 'lighthouse-matchers'
  spec.version       = Lighthouse::Matchers::VERSION
  spec.authors       = ['Josh McArthur on behalf of Ackama']
  spec.email         = ['josh.mcarthur@ackama.com']

  spec.summary       = <<~DESC
    Provides RSpec matchers for executing and evaluating Lighthouse audit scores
  DESC
  spec.homepage = 'https://github.com/ackama/lighthouse-matchers'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/ackama/lighthouse-matchers'
    spec.metadata['changelog_uri'] = 'https://github.com/ackama/lighthouse-matchers/blob/master/CHANGELOG.md'
    spec.metadata['rubygems_mfa_required'] = 'true'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webrick'
end
