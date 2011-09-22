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

dep('rvm installed') {
  met? {
    shell("type rvm | head -1", :user => 'vagrant') == 'function'
  }

  meet {
    shell('wget http://rvm.beginrescueend.com/install/rvm -O ~/rvm.sh', :user => 'vagrant')
    shell('chmod +x ~/rvm.sh', :user => 'vagrant')
    shell('~/rvm.sh', :user => 'vagrant')
    shell('rm -f ~/rvm.sh', :user => 'vagrant')
    shell("mkdir -p /etc/profile.d", :sudo => true, :user => 'vagrant')
    render_erb 'rvm/rvm.sh.erb', :to => '/etc/profile.d/rvm.sh', :perms => '755', :sudo => true, :user => 'vagrant'
  }
}

meta(:rvm) {
  accepts_list_for :rubies

  requires ['rvm installed']

  met? {
    rubies.select { |ruby_version|
      shell("rvm list | grep #{ruby_version}", :user => 'vagrant')
    }.size == rubies.size
  }

  meet {
    rubies.each do |ruby_version|
      shell("rvm install #{ruby_version}", :user => 'vagrant')
    end
  }
}

dep('rubies installed.rvm') {
  rubies ['ruby-1.8.7', 'ruby-1.9.2']
}

dep 'vagrant user exists' do
  def username
    var(:username, :default => 'vagrant')
  end
  setup {
    define_var :home_dir_base, :default => L{
      username['.'] ? '/srv/http' : '/home'
    }
  }
  on :linux do
    met? { grep(/^#{username}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p #{var :home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{var(:username)}" and
      sudo "chmod 701 #{var(:home_dir_base) / var(:username)}"
    }
  end
end

dep('vagrant host setup') {
  requires ['vagrant host dependencies', 'vagrant user exists', 'rvm installed', 'rubies installed.rvm']
}
