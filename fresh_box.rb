dep('fresh box') {
  requires [
    'benhoskings:system',
    'benhoskings:core software',
    'fail2ban.managed',
    'benhoskings:user setup for provisioning',
    'benhoskings:passwordless sudo',
    'benhoskings:secured ssh logins',
    'user can write to usr local',
    'benhoskings:passwordless ssh logins'
  ]
}

dep('fail2ban.managed') {
  installs []
}
