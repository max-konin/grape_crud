source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem 'bundler'
  gem 'rake'
  gem 'rubocop', '0.51.0'
  gem 'yard'
end

group :test do
  gem 'activemodel'
  gem 'coveralls', '~> 0.8.17', require: false
  gem 'grape-entity', '~> 0.6'
  gem 'mime-types'
  gem 'rack-test', '~> 0.6.3'
  gem 'rspec', '~> 3.0'
  gem 'rspec-mocks'
  gem 'will_paginate'
end
