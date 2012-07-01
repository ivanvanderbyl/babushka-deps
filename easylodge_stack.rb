dep('easylodge stack bootstrap') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

  requires [
    'benhoskings:system',
    'ivanvanderbyl:ruby.src'.with('1.9.2','p290'),
    'benhoskings:user setup for provisioning',
    'testpilot:core dependencies',
    'testpilot:build essential installed',
    'testpilot:nodejs.src',
    'benhoskings:core software',
    'benhoskings:passwordless sudo'
  ]
}

dep('easylodge stack') {
  setup {
    unmeetable! "This dep cannot be run as root." if shell('whoami') == 'root'
  }

  requires 'testpilot:core dependencies',
    'benhoskings:imagemagick.managed',
    'benhoskings:secured ssh logins',
    'libmysqlclient-dev.managed',
    'mysql-client.managed',
    'ivanvanderbyl:running.nginx',
    'postgresql.managed',
    'testpilot:sphinx installed'.with('0.9.9'),
    'vhost enabled.nginx'
}

dep('libmysqlclient-dev.managed'){
  provides []
}

dep('mysql-client.managed') {
  provides ['mysql']
  installs 'mysql-client'
}

