packages = [
  'lsof',
  'iptables',
  'jwhois',
  'whois',
  'curl',
  'wget',
  'rsync',
  'jnettop',
  'nmap',
  'traceroute',
  'ethtool',
  'iproute',
  'iputils-ping',
  'netcat-openbsd',
  'tcpdump',
  'elinks',
  'lynx',
  'bind9-host'
].each do |package|
  dep [package, 'managed'].join('.')
end

# dep('bootstrap vagrant host'){
#   requires packages | ['git']
#
#   met? { false }
#
#   meet {}
# }

dep('vagrant host dependencies.managed') {
  requires packages.map { |p| "#{p}.managed" }
  # provides %w[lsof jwhois whois curl wget rsync jnettop nmap traceroute ethtool iproute iputils netcat tcpdump elinks lynx bind9 make gcc]
}
