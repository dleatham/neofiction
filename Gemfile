################################################################################
# gem source
source 'http://rubygems.org'

################################################################################
# Mandatory Gems
ruby '1.9.3'
gem 'rails', '3.2.16'
gem 'pg'
gem 'json' 
# gem 'pry'


################################################################################
# Additional gems to be used in this application
gem 'jquery-rails', "~> 2.3.0"
# gem 'jquery-rails'
gem 'cancan'
gem 'devise', '1.5.3'
# gem 'will_paginate', '~> 3.0'
gem "kaminari"
gem 'ancestry'
gem 'on_the_spot'
# gem 'thumbs_up', '~> 0.4.4'
gem 'thumbs_up'
gem 'faker'
gem "thin"
gem "recaptcha", :require => "recaptcha/rails"
gem 'friendly_id'



################################################################################
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  # javascript interpreter
  gem 'therubyracer'

  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

################################################################################
# Project gems for deployment
gem 'heroku'
  

################################################################################
# development gems
group :development do
  # To use debugger
  # gem 'ruby-debug19', :require => 'ruby-debug'
  #  gem 'ruby-debug19'
  gem "nifty-generators"
  gem 'pry'  # invoke from command line with: >  pry -r ./config/environment
  gem 'pry-rails'
  # gem 'pry-remote'
  gem 'pry-nav'   # break point:   binding.pry
end

################################################################################
# testing gem
group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'minitest'
end
gem "mocha", :group => :test
