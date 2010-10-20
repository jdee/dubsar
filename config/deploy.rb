set :user, 'dubsar'
set :domain, 'dubsar-dictionary.com'
set :application, "dubsar"
set :repository,  "git@github.com:jdee/dubsar.git"
set :use_sudo, false
set :deploy_to, "/var/lib/#{application}"
set :scm, :git

role :web, domain
role :app, domain
role :db,  domain, :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true

namespace :deploy do
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
