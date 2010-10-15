#server used for capistrano deploy
server_name = 'calculon.appfission.com'
#not configurable beyond here

app_name = Dir.pwd.split('/').last
app_class_name = app_name.capitalize
base_path = File.dirname(__FILE__)

gem 'capistrano'
gem 'capybara'
gem 'cucumber'
gem 'cucumber-rails'
gem 'database_cleaner'
gem 'devise'
gem 'faker'
gem 'formtastic'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'launchy'
gem 'machinist'
gem 'pickle'
gem 'redis'
gem 'redis-store', '1.0.0.beta3'
gem 'rspec-rails'
gem 'spork'
gem 'will_paginate'
gem 'validation_reflection'

template = ERB.new(File.read(base_path + '/database.yml.erb'))
File.open('config/database.yml', 'w') {|f| f << template.result(binding) }
run 'bundle'

FileUtils.rm_rf 'test'
FileUtils.rm 'public/index.html'

#TATFT
generate "rspec:install"
FileUtils.cp File.join(base_path, 'spec_helper.rb'), 'spec/spec_helper.rb'
FileUtils.cp File.join(base_path, 'blueprints.rb'), 'spec/blueprints.rb'
generate "cucumber:install", "--capybara --rspec --spork"
generate "pickle", "--paths -f"

#redis
inject_into_file "config/application.rb", :after => "config.filter_parameters += [:password]\n" do
  "config.cache_store = :redis_store"
end

template = ERB.new(File.read(base_path + '/session_store.rb.erb'))
File.open('config/initializers/session_store.rb', 'w') {|f| f << template.result(binding) }

#others
generate "formtastic:install"
generate 'jquery:install', '-f'
generate "devise:install"
generate "devise", "User"

FileUtils.rm 'app/views/layouts/application.html.erb'
FileUtils.cp File.join(base_path, 'application.html.haml'), 'app/views/application.html.haml'

capify!
template = ERB.new(File.read(base_path + '/deploy.rb.erb'))
File.open('config/deploy.rb', 'w') {|f| f << template.result(binding) }

git :init

git :add => '.'
git :commit => '-a -m "Initial Commit"'
