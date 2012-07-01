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
           'mysql-devel.managed',
           'mysql-client.managed',
           'benhoskings:mysql.gem',
           'benhoskings:secured ssh logins',
           'ivanvanderbyl:running.nginx',
           'vhost enabled.nginx'.with('unicorn', 'easylodge.com.au')
}

dep('mysql-devel.managed'){
  provides []
  installs 'libmysqlclient15-dev'
}

dep('mysql-client.managed') {
  provides ['mysql']
  installs 'mysql-client'
}

