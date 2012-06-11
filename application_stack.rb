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
    'benhoskings:postgres.managed'
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
