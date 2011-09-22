dep('bootstrap vagrant host'){
  requires [
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
  ]
}