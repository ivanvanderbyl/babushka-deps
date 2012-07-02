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
libmysqlclient-dev  }

  requires [
    'testpilot:core dependencies',
    'benhoskings:secured ssh logins',
    'user can write to usr local',
    'ivanvanderbyl:running.nginx',
    'postgres access',
    'vhost enabled.nginx',
    'bundler.gem'
  ]

}

dep('postgresql.managed') {
  installs ['postgresql-9.1', 'postgresql-server-dev-9.1']
  provides %w(pg pg_basebackup pg_config pg_createcluster
              pg_ctlcluster pg_dropcluster pg_dump pg_dumpall pg_lsclusters
              pg_restore pg_upgradecluster)
}

dep 'postgres access', :username do
  requires 'postgresql.managed'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{username}\b/).empty? }
  meet { sudo "createuser -SdR #{username}", :as => 'postgres' }
end
