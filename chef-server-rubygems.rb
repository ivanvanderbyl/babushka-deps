dep('bootstrap chef server with rubygems') {
  requires [
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'chef.gem',
    'ohai.gem'
  ]
}

dep('rubygems with no docs') {
  met? {
    File.exists?("/etc/gemrc") &&
    !sudo('cat /etc/gemrc').split("\n").grep(/(^gem:)/).empty?
  }
  
  meet {
    shell('echo "gem: --no-ri --no-rdoc" > /etc/gemrc', :sudo => true)
  }
}

dep('chef install dependencies.managed') {
  installs %w[irb build-essential wget ssl-cert]
  provides %w[wget make irb gcc]
}

dep 'chef.gem' do
  installs 'chef ~> 0.9.16'
  provides 'chef-client'
end

dep 'ohai.gem' do
  installs 'ohai'
end