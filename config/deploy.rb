# config valid only for Capistrano 3.1
# lock '3.1.0'

set :application, 'shopshow'
# set :scm, :git
set :repo_url, 'git@github.com:shopshow/shopshow-1.0.git'
# set :branch, "master"
set :rails_env, 'production'
set :deploy_to, -> { "/home/shopshow/www/#{fetch(:application)}" }
set :rvm_type, :user
set :rvm_ruby_version, '2.1.0'

set :linked_files, %w{config/database.yml config/secrets.yml config/config.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/uploads}

set :keep_releases, 10
set :default_shell, '/bin/bash -l'

# set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
# set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 2"

namespace :deploy do
 desc "Start Application"
  task :start do
    on roles(:app) do
      with :rails_env => fetch(:rails_env) do
        within release_path do
          execute :bundle, 'exec unicorn_rails -c config/unicorn.rb -D'
        end
      end        
    end
  end

  desc "Stop Application"
  task :stop do
    on roles(:app) do
      execute "kill -QUIT `cat #{current_path}/tmp/pids/unicorn.pid`"
    end
  end

  desc "Restart Application"
  task :restart do
    on roles(:app) do
      execute "kill -USR2 `cat #{current_path}/tmp/pids/unicorn.pid`"
      invoke 'delayed_job:restart'
    end
  end

  before 'deploy:start', 'rvm:hook'
  after :publishing, 'deploy:restart'
end
