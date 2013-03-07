dep('fresh box') {
  requires [
    'benhoskings:system',
    'benhoskings:core software',
    'fail2ban.managed',
    'benhoskings:user setup for provisioning',
    'benhoskings:passwordless sudo',
    'benhoskings:secured ssh logins',
    'user can write to usr local',
    'benhoskings:passwordless ssh logins',
    'automatic updates configured'
  ]
}

dep('fail2ban.managed') {
  installs []
}

dep('automatic updates configured') {
  requires 'unattended-upgrades.managed'

  met? {
    Babushka::Renderable.new("/etc/apt/apt.conf.d/10periodic").from?(dependency.load_path.parent / "apt/10periodic.erb") and
    Babushka::Renderable.new("/etc/apt/apt.conf.d/50unattended-upgrades").from?(dependency.load_path.parent / "apt/50unattended-upgrades.erb")
  }

  meet {
    render_erb "apt/10periodic.erb", :to => "/etc/apt/apt.conf.d/10periodic", :sudo => true
    render_erb "apt/50unattended-upgrades.erb", :to => "/etc/apt/apt.conf.d/50unattended-upgrades", :sudo => true
  }
}

dep('unattended-upgrades.managed') {
  installs []
}