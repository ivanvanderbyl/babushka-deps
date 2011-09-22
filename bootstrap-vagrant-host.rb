packages = [
  'lsof.managed',
  'iptables.managed',
  'jwhois.managed',
  'whois.managed',
  'curl.managed',
  'wget.managed',
  'rsync.managed',
  'jnettop.managed',
  'nmap.managed',
  'traceroute.managed',
  'ethtool.managed',
  'iproute.managed',
  'iputils-ping.managed',
  'netcat-openbsd.managed',
  'tcpdump.managed',
  'elinks.managed',
  'lynx.managed',
  'bind9-host.managed'
].each do |package|
  dep package
end

dep('bootstrap vagrant host'){
  requires packages | ['git']

  met? { false }

  meet {}
}

dep('vagrant host dependencies.managed') {
  installs packages | %w[build-essential]
  provides %w[lsof iptables jwhois whois curl wget rsync jnettop nmap traceroute ethtool iproute iputils netcat tcpdump elinks lynx bind9 make gcc]
}
