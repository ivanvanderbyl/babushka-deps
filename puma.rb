dep('puma on upstart') {
  requires 'puma upstart config rendered'
}

dep('puma upstart config rendered') {
  requires 'puma apps configured'

  def config_path
    '/etc/init'
  end

  def puma_config_path
    config_path / 'puma.conf'
  end

  def puma_manager_config_path
    config_path / 'puma-manager.conf'
  end

  met? {
    Babushka::Renderable.new(puma_config_path).from?(dependency.load_path.parent / "puma/puma.conf.erb") &&
    Babushka::Renderable.new(puma_manager_config_path).from?(dependency.load_path.parent / "puma/puma-manager.conf.erb")
  }

  meet {
    render_erb dependency.load_path.parent / 'puma/puma.conf.erb', :to => puma_config_path, :sudo => true
    render_erb dependency.load_path.parent / 'puma/puma-manager.conf.erb', :to => puma_manager_config_path, :sudo => true
  }
}

dep('puma apps configured', :deployment_paths) {
  deployment_paths.default(File.expand_path('~/current')).ask('Applications to run under Puma (paths separated by spaces)')

  def puma_config_path
    '/etc/puma.conf'
  end

  def app_paths
    deployment_paths.to_s.split(' ').join("\n")
  end

  met? {
    Babushka::Renderable.new(puma_config_path).from?(dependency.load_path.parent / "puma/etc/puma.conf.erb")
  }

  meet {
    render_erb dependency.load_path.parent / 'puma/etc/puma.conf.erb', :to => puma_config_path, :sudo => true
  }
}