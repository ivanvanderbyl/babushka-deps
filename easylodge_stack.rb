# Configures a blank instance with everything we need to get a stack installed.
#
# This dep must be run as root.
#
# During this dep you will be asked for your SSH pub key to allow authentication
# as the user you specify during installation e.g deploy
dep('easylodge deployable') {
  setup {
    unmeetable! "This dep has to be run as root." unless shell('whoami') == 'root'
  }

  requires [
    'benhoskings:system',
    'testpilot:ruby dependencies',
    'ivanvanderbyl:ruby.src'.with('1.9.2','p320'),
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
    'user can write to usr local',
    'libmysqlclient-dev.managed',
    'mysql-client.managed',
    'ivanvanderbyl:running.nginx',
    'postgresql.managed',
    'testpilot:sphinx installed'.with('0.9.9'),
    'vhost enabled.nginx',
    'prince xml installed',
    'bundler.gem'
}

dep('libmysqlclient-dev.managed'){
  provides []
}

dep('mysql-client.managed') {
  provides ['mysql']
  installs 'mysql-client'
}

dep('user can write to usr local') {
  def user
    shell 'whoami'
  end

  met? {
    shell? "touch /usr/local/lib/touch-this" &&
    shell? 'rm /usr/local/lib/touch-this'
  }

  meet {
    shell "chown -R #{user}:#{user} /usr/local/", :sudo => true
  }
}
