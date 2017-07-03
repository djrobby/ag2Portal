# LAMP including Sidekiq (redis-server must be installed in LAMP previously)
# Choose a Ruby explicitly, or read from an environment variable.
set :rvm_ruby_string, :local               # use the same ruby as used locally for deployment
set :rvm_type, :user
set :rvm_autolibs_flag, "read-only"        # more info: rvm help autolibs

before 'deploy', 'rvm:install_rvm'  # update RVM
before 'deploy', 'rvm:install_ruby' # install Ruby and create gemset (both if missing)

# Load RVM's capistrano plugin.
require 'rvm/capistrano'
# Use bundler to install requiered gems after update_code
require "bundler/capistrano"
# Requiere sidekiq
#require 'sidekiq/capistrano'
require 'capistrano/sidekiq'

# be sure to change these
set :user, 'nestor'
set :domain, 'lamp'
set :application, 'agestiona2'

# file paths
set :repository,  "#{user}@#{domain}:git/#{application}.git"
set :deploy_to, "/home/#{user}/#{application}"

# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain
# Deploy DB to 'lamp'
role :db, "lamp", :primary => true

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

# miscellaneous options
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, false
set :bundle_flags,    ""

before "deploy", "deploy:check_revision"
after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
end
