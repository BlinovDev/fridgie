# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

# App identity
set :application, "fridgie"
set :repo_url, "git@github.com:BlinovDev/fridgie.git"
set :branch, ENV.fetch("BRANCH", "main")

# Deploy directory on server
set :deploy_to, "/var/www/#{fetch(:application)}"

# Ruby via rbenv
set :rbenv_type, :user
set :rbenv_ruby, "3.4.4"

# Linked files/dirs (shared between releases)
append :linked_files, "config/master.key", ".env", "config/database.yml" # if you use dotenv
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets",
       "public/assets", "storage", "node_modules"

# bundler
set :bundle_without, %w[test development].join(' ')

# Keep releases
set :keep_releases, 3

# Yarn (run before assets:precompile)
before "deploy:assets:precompile", "yarn:install"

# Puma setup
set :puma_user, fetch(:user, "deploy")
set :puma_threads, [3, 5]
set :puma_workers, 2
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log,  "#{shared_path}/log/puma_error.log"
set :puma_env, fetch(:rack_env, fetch(:rails_env, "production"))
set :puma_init_active_record, true
