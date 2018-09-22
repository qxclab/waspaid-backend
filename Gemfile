source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'
# base
gem 'rails', '~> 5.2.1'
gem 'pg', '~> 1.1', '>= 1.1.3'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rack-cors'

# auth
gem 'devise', '~> 4.2'
gem 'devise-jwt', '~> 0.5.8'

group :test do
  gem 'json-schema'
end

group :development, :test do
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
  end
  gem 'fabrication', '~> 2.20', '>= 2.20.1'
  gem 'faker', '~> 1.9', '>= 1.9.1'
  gem 'coveralls', require: false
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
