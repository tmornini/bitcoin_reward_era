# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bitcoin_reward_era/version'

Gem::Specification.new do |spec|
  spec.name          = 'bitcoin_reward_era'
  spec.version       = BitcoinRewardEra::VERSION
  spec.authors       = ['Tom Mornini']
  spec.email         = ['tom@subledger.com']

  spec.summary       = 'Bitcoin reward era gem'

  spec.description   = "Bitcoin reward era gem.\n" \
                       '100% BigDecimal math (not Float or Fixnum).'

  spec.homepage      = 'https://github.com/tmornini/bitcoin_reward_era'
  spec.license       = 'MIT'

  spec.files         =
    `git ls-files -z`.split("\x0").reject { |f| f.match(/_spec.rb$/) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename f }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',            '~> 1.8'
  spec.add_development_dependency 'rake',               '~> 10'
  spec.add_development_dependency 'minitest',           '~> 5.5', '>= 5.5.1'
  spec.add_development_dependency 'rspec-expectations', '~> 3.2'
  spec.add_development_dependency 'rspec-mocks',        '~> 3.2'
  spec.add_development_dependency 'rubocop',            '~> 0.29'
end
