# config valid only for current version of Capistrano

lock '3.4.0'
# Эти параметры необходимо поменять
set :application, 'ostagram'
set :username, 'deploy'



set :repo_url, 'git@github.com:SergeyMorugin/ostagram.git'
set :reils_env, 'production'
set :branch, 'develop'
#set :shared_path, ''
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/home/#{fetch(:username)}/server/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, %w{config/secrets.yml config/database.yml config/config.secret}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, %w{bundle}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :default_env, {rvm_bin_path: '~/.rvm/bin'}


namespace :setup do
  desc 'Загрузка конфигурационных файлов на удаленный сервер'
  task :upload_config do
    on roles :all do
      execute :mkdir, "-p #{shared_path}"
      ['shared/config', 'shared/run', 'shared/log', 'shared/db'].each do |f|
        upload!(f, shared_path, recursive: true)
      end
    end
  end

  task :setup do
    on roles(:all) do
      # Upload config files
      execute :mkdir, "-p #{shared_path}"
      ['shared/config', 'shared/run', 'shared/log', 'shared/db'].each do |f|
        upload!(f, shared_path, recursive: true)
      end
      #before "deploy:migrate", :create_db
      # Make simlink to nginx config
      sudo :ln, "-fs #{shared_path}/config/unicorn.conf /etc/nginx/conf.d/#{fetch(:application)}.conf"
      invoke :deploy
    end
  end
end

namespace :nginx do
  desc 'Создание симлинка в /etc/nginx/conf.d на nginx.conf приложения'
  task :append_config do
    on roles :all do
      sudo :ln, "-fs #{shared_path}/config/unicorn.conf /etc/nginx/conf.d/#{fetch(:application)}.conf"
    end
  end
  desc 'Релоад nginx'
  task :reload do
    on roles :all do
      sudo :service, :nginx, :reload
    end
  end
  desc 'Рестарт nginx'
  task :restart do
    on roles :all do
      sudo :service, :nginx, :restart
    end
  end
  task :create_db do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "db:create"
        end
      end
    end
  end

  after :append_config, :restart
end

set :unicorn_config, "#{shared_path}/config/unicorn.rb"
set :unicorn_pid, "#{shared_path}/run/unicorn.pid"

namespace :application do
  desc 'Запуск Unicorn'
  task :start do
    on roles(:all) do

      within release_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{release_path} && (RAILS_ENV=#{fetch(:stage)}  ~/.rvm/bin/rvm default do bundle exec unicorn -c #{fetch(:unicorn_config)} -D)"
          #execute :bundle, "exec unicorn -c #{fetch(:unicorn_config)}"
        end
      end
      #execute "cd #{fetch(:deploy_to)}/current"
      #{fetch(:deploy_to)}/current
      #execute "~/.rvm/bin/rvm default"
      #:bundle, :exec,
      #run "#{fetch(:deploy_to)}/current/bundle exec unicorn_rails -c #{fetch(:unicorn_config)} -E production -D"
      #execute bundl exec unicorn_rails -D"
    end
  end
  desc 'Завершение Unicorn'
  task :stop do
    on roles(:app) do
      execute "if [ -f #{fetch(:unicorn_pid)} ] && [ -e /proc/$(cat #{fetch(:unicorn_pid)}) ]; then kill -9 `cat #{fetch(:unicorn_pid)}`; fi"
    end
  end
end




namespace :deploy do
  desc 'Подготовка deploy'

  task :migrate do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{release_path} && (RAILS_ENV=#{fetch(:stage)}  ~/.rvm/bin/rvm default do rake db:migrate)"
        end
      end
    end
  end


  namespace :linking do
    desc 'Создание симлинка на изображения'
    task :uploads do
      on roles :all do
        sudo :ln, "-s /home/deploy/disk600/server/ostagram/public/uploads #{release_path}/public/uploads "
      end
    end
  end

  task :precompile do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{release_path} && (RAILS_ENV=#{fetch(:stage)}  ~/.rvm/bin/rvm default do rake assets:precompile)"
        end
      end
    end
  end


  #before 'deploy:setup', 'git:push'
  after :finishing, 'deploy:migrate'
  after :finishing, 'linking:uploads'
  after :finishing, 'deploy:precompile'
 # after :finishing, 'application:stop'
  #after :finishing, 'application:stop'
  #after :finishing, 'application:start'
  #after :finishing, 'nginx:reload'
  after :finishing, :cleanup
  #after :restart, :clear_cache do
  # on roles(:web), in: :groups, limit: 3, wait: 10 do
  # Here we can do anything such as:
  # within release_path do
  #   execute :rake, 'cache:clear'
  # end
  #end
  #end
end