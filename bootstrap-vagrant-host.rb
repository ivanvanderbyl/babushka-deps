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
  'tcpdump',
  'elinks',
  'lynx',
  'bind9-host'
].each do |package|
  dep [package, 'managed'].join('.')
end

packages_without_binary = ['iproute', 'iputils-ping', 'netcat-openbsd'].each { |p|
  dep [p, 'managed'].join('.') do
    provides []
  end
}

dep('vagrant host dependencies.managed') {
  requires (packages + packages_without_binary).map { |p| "#{p}.managed" }
}

