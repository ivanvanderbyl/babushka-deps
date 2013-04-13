dep('fresh box') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

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

dep('ruby application stack') {
  setup {
    unmeetable! "This dep cannot be run as root." if shell('whoami') == 'root'
  }

  requires [
    'ivanvanderbyl:ruby.src'.with('2.0.0', 'p0'),
    'ivanvanderbyl:running.nginx',
    # 'vhost enabled.nginx',
    'configured.nginx'.with('/opt/nginx'),
    'dot files setup',
    'postgresql-dev.managed',
    'bundler.gem',
    'testpilot:nodejs.src'.with('0.10.4')
  ]
}

dep('postgres database master stack') {
  requires 'postgres access'
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