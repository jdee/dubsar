#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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

# From rvm.beginrescueend.com
$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.

set :rvm_ruby_string, 'ree@rails3'        # Or whatever env you want it to run in.

set :user, 'dubsar'
set :domain, 'dubsar-dictionary.com'
set :application, "dubsar"
set :repository,  "git@github.com:jdee/dubsar.git"
set :use_sudo, false
set :deploy_to, "/var/lib/#{application}"
set :scm, :git
set :rails_env, 'production'

role :web, domain
role :app, domain
role :db,  domain, :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true

namespace :deploy do
  desc 'Create asset packages for production'
  task :package_assets, :roles => :app do
    run <<-EOF
      cd #{deploy_to}/current && /usr/local/rvm/gems/ree-1.8.7-2010.02/bin/bundle exec rake RAILS_ENV=production asset:packager:build_all
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
end

after 'deploy:update', 'deploy:package_assets'
