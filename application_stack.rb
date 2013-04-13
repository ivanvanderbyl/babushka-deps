dep('application deployable') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

  requires [
    'benhoskings:system',
    'testpilot:ruby dependencies',
    'ivanvanderbyl:ruby.src',
    'benhoskings:user setup for provisioning',
    'testpilot:core dependencies',
    'testpilot:build essential installed',
    'testpilot:nodejs installed',
    'benhoskings:core software',
    'benhoskings:passwordless sudo',
    'postgresql.managed'
  ]
}

dep('application deployed', :domain){
  setup {
    unmeetable! "This dep cannot be run as root." if shell('whoami') == 'root'
  }

  requires [
    'testpilot:core dependencies',
    'benhoskings:secured ssh logins',
    'user can write to usr local',
    'ivanvanderbyl:running.nginx',
    'postgres access',
    'vhost enabled.nginx',
    'profile setup',
    'bundler.gem',
    'testpilot:java installed'
  ]

}

dep('postgresql.managed') {
  installs ['postgresql-9.1', 'postgresql-server-dev-9.1', 'postgresql-contrib']
  provides %w(pg  pg_config pg_createcluster
              pg_ctlcluster pg_dropcluster pg_dump pg_dumpall pg_lsclusters
              pg_restore pg_upgradecluster)
}

dep('postgresql-dev.managed') {
  installs ['postgresql-server-dev-9.2', 'postgresql-contrib']
  provides []
}

dep 'postgres access', :username do
  requires 'postgresql.managed'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{username}\b/).empty? }
  meet { sudo "createuser -SdR #{username}", :as => 'postgres' }
end

dep('profile setup', :deploy_to) do
  deploy_to.default("current")

  def user
    shell('whoami')
  end

  def dot_profile_path
    File.expand_path("~/.profile")
  end

  def current_path
    path = deploy_to.to_s.gsub(/\/$/, '')
    if path =~ /^\~/
      path = File.expand_path(path)
    end
    path
  end

  met? {
    dot_profile_path.p.grep(/console/)
  }

  meet { render_erb 'profile/dot.profile.erb', :to => dot_profile_path, :sudo => false }
end
