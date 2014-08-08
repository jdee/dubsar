#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'bundler/capistrano'
require "rvm/capistrano"                  # Load RVM's capistrano plugin.

set :rvm_ruby_string, 'ruby-2.0.0-p481'        # Or whatever env you want it to run in.

set :user, 'dubsar'
set :domain, 'dubsar-dictionary.com'
set :application, "dubsar"
set :repository,  "http://github.com/jdee/dubsar.git"
set :use_sudo, false
set :deploy_to, "/var/lib/#{application}"
set :scm, :git
set :rails_env, 'production'
set :rvm_type, :system
set(:shared_database_path) {"#{shared_path}/databases"}
set(:shared_config_path) {"#{shared_path}/config"}
set :secret_token_path, "config/initializers/secret_token.rb"

role :web, domain
role :app, domain
role :db,  domain, :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true

namespace :deploy do
  desc 'Build wotd RSS feed'
  task :wotd_build, :roles => :app do
    run <<-EOF
      cd #{deploy_to}/current && bundle exec rake RAILS_ENV=#{rails_env} wotd:build
    EOF
  end

  desc 'Optimize inflections_fts table'
  task :optimize_fts, :roles => :app do
    run <<-EOF
      cd #{deploy_to}/current && bundle exec rake RAILS_ENV=#{rails_env} fts:optimize
    EOF
  end

  desc 'start the remote Dubsar instance'
  task :start, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :stop do ; end

  desc 'start the remote Dubsar instance'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Links the client_secrets.yml file"
  task :link_client_secrets do
    run "ln -nsf #{shared_config_path}/client_secrets.yml #{release_path}/config/production_client_secrets.yml"
    run "ln -nsf #{shared_config_path}/client_secrets.yml #{release_path}/config/backup_client_secrets.yml"
  end

  desc "Links to devise config"
  task :link_devise_config do
    run "ln -nsf #{shared_config_path}/devise_config.rb #{release_path}/config/initializers/devise.rb"
  end

  desc "Links the database for download"
  task :link_wn31_db do
    YAML::load_file(File.expand_path('config/downloads.yml', Rails.root)).each do |k, v|
      zipfile = "#{k}.zip"
      run "ln -nsf #{shared_database_path}/#{zipfile} #{File.join(current_path, 'public', zipfile)}"
    end
  end

  desc "Generates a new secret"
  task :update_secret do
    run <<-EOF
      cd #{deploy_to}/current &&
      echo "Dubsar::Application.config.secret_key_base = '" > #{secret_token_path} &&
      bundle exec rake secret >> #{secret_token_path} &&
      echo "'" >> #{secret_token_path}
    EOF
  end
end

# from http://www.bagonca.com/blog/2009/05/09/rails-deploy-using-sqlite3/
namespace :sqlite3 do
  desc "Generate a database configuration file"
  task :build_configuration, :roles => :db do
    db_options = {
      "adapter"  => "sqlite3",
      "database" => "#{shared_database_path}/production.sqlite3"
    }
    config_options = {"production" => db_options}.to_yaml
    put config_options, "#{shared_config_path}/sqlite_config.yml"
  end

  desc "Links the configuration file"
  task :link_configuration_file do
    run "ln -nsf #{shared_config_path}/sqlite_config.yml #{release_path}/config/database.yml"
  end

  desc "Make a shared database folder"
  task :make_shared_folder, :roles => :db do
    run "mkdir -p #{shared_database_path}"
  end
end

namespace :pusher do
  desc "Build the pusher"
  task :build do
    run "cd #{deploy_to}/current/pusher && /usr/bin/make"
  end
end

after "deploy:setup", "sqlite3:make_shared_folder"

after 'deploy:update', 'sqlite3:build_configuration'
after 'deploy:update', 'sqlite3:link_configuration_file'
after 'deploy:update', 'deploy:link_client_secrets'
after 'deploy:update', 'deploy:wotd_build'
after 'deploy:update', 'deploy:update_secret'
after 'deploy:update', 'deploy:link_devise_config'
after 'deploy:update', 'deploy:link_wn31_db'
after 'deploy:update', 'pusher:build'
# after 'deploy:update', 'deploy:optimize_fts'

before "deploy:migrate", "sqlite3:link_configuration_file"
