namespace :puma do
  desc 'Restart Puma via systemd (system-wide unit)'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, 'puma-fridgie'
    end
  end

  desc 'Start Puma via systemd'
  task :start do
    on roles(:app) do
      execute :sudo, :systemctl, :start, 'puma-fridgie'
    end
  end

  desc 'Stop Puma via systemd'
  task :stop do
    on roles(:app) do
      execute :sudo, :systemctl, :stop, 'puma-fridgie'
    end
  end

  desc 'Show Puma status'
  task :status do
    on roles(:app) do
      execute :sudo, :systemctl, :status, 'puma-fridgie'
    end
  end
end

after 'deploy:publishing', 'puma:restart'
