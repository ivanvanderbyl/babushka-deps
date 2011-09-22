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
  'lynx'
].each do |package|
  dep [package, 'managed'].join('.')
end

packages_without_binary = [
  'iproute',
  'iputils-ping',
  'netcat-openbsd',
  'bind9-host',
  'libreadline5-dev',
  'libssl-dev',
  'libxml2-dev',
  'libxslt1-dev',
  'zlib1g-dev'
].each { |p|
  dep [p, 'managed'].join('.') do
    provides []
  end
}

dep('vagrant host dependencies') {
  requires (packages + packages_without_binary).map { |p| "#{p}.managed" }
}

# dep('rvm installed') {
#   met? {
#     sudo("type rvm | head -1", :as => 'vagrant') == 'function'
#   }
#
#   meet {
#     sudo('wget http://rvm.beginrescueend.com/install/rvm -O /home/vagrant/rvm.sh', :as => 'vagrant')
#     sudo('chmod +x /home/vagrant/rvm.sh', :as => 'vagrant')
#     sudo('/home/vagrant/rvm.sh', :as => 'vagrant')
#     sudo('rm -f /home/vagrant/rvm.sh', :as => 'vagrant')
#     sudo("mkdir -p /etc/profile.d")
#     render_erb 'rvm/rvm.sh.erb', :to => '/etc/profile.d/rvm.sh', :perms => '755', :sudo => true
#   }
# }
#
# meta(:rvm) {
#   accepts_list_for :rubies
#
#   template {
#     requires ['rvm installed']
#
#     met? {
#       rubies.select { |ruby_version|
#         shell("rvm list | grep #{ruby_version}", :as => 'vagrant')
#       }.size == rubies.size
#     }
#
#     meet {
#       rubies.each do |ruby_version|
#         shell("rvm install #{ruby_version}", :as => 'vagrant')
#       end
#     }
#   }
# }
#
# dep('rubies installed.rvm') {
#   rubies ['ruby-1.8.7', 'ruby-1.9.2']
# }

dep 'vagrant user exists' do
  def username
    'vagrant'
  end

  requires ['admins can sudo']

  on :linux do
    met? { grep(/^#{username}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p /home" and
      sudo "useradd -m -s /bin/bash -b /home -G admin #{username}" and
      sudo "chmod 701 #{'/home' / username}"

      Dep('can sudo without password')
      Dep('passwordless ssh logins')
    }
  end
end

dep('vagrant host setup') {
  requires ['vagrant host dependencies', 'vagrant user exists', 'ruby19.src' ]
}
