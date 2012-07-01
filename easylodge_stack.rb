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

  requires 'benhoskings:imagemagick.managed',
           'libmysqlclient15-dev.managed',
           'mysql-client.managed',
           'benhoskings:mysql.gem',
           'benhoskings:secured ssh logins',
           'ivanvanderbyl:running.nginx',
           'vhost enabled.nginx'.with('unicorn', 'easylodge.com.au')
}

dep('libmysqlclient15-dev.managed'){
  provides []
  installs 'libmysqlclient-dev'
}

dep('mysql-client.managed') {
  provides ['mysql']
  installs 'mysql-client'
}

