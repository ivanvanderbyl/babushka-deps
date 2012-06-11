dep('application deployable') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

  requires [
    'benhoskings:system',
    'ivanvanderbyl:ruby.src',
    'benhoskings:user setup for provisioning',
    'testpilot:core dependencies',
    'testpilot:build essential installed',
    'libv8-dev.managed',
    'benhoskings:core software',
    'postgresql.managed'
  ]
}

dep('application deployed', :domain){
  setup {
    unmeetable! "This dep cannot be run as root." if shell('whoami') == 'root'
  }

  requires [
    'benhoskings:passwordless sudo',
    'benhoskings:secured ssh logins',
    'ivanvanderbyl:running.nginx',
    'postgres access',
    'vhost enabled.nginx'.with('unicorn', domain)
  ]

}

dep('libv8-dev.managed') {
  provides []
}

dep('postgresql.managed') {
  installs ['postgresql-9.1']
  provides %w(pg pg_basebackup pg_config pg_createcluster
              pg_ctlcluster pg_dropcluster pg_dump pg_dumpall pg_lsclusters
              pg_restore pg_updatedicts pg_upgradecluster)
}
