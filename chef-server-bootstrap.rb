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

dep('bootstrap chef') { requires 'bootstrap chef server with rubygems' }

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

dep('chef.gem'){
  installs 'chef ~> 0.9.16'
  provides 'chef-client'
}

dep('ohai.gem') {
  installs 'ohai'
}

dep('chef solo') {
  requires [
    'chef solo configuration',
    'chef bootstrap configuration'
  ]
  met? {
    false
  }
  meet {
    log_shell "Downloading latest chef bootstrap", 'chef-solo -c /etc/chef/solo.rb -j ~/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz', :spinner => true, :sudo => !File.writable?("/etc/chef/solo.rb")
  }
}

dep('chef solo configuration') {
  met?{ File.exists?("/etc/chef/solo.rb") }
  meet {
    shell("mkdir -p /etc/chef", :sudo => true)
    render_erb 'chef/solo.rb.erb', :to => '/etc/chef/solo.rb', :perms => '755', :sudo => true
  }
}

dep('chef bootstrap configuration') {
  def chef_json_path
    File.expand_path("~/chef.json")
  end
  
  met?{ File.exists?(chef_json_path) }
  meet {
    shell("cat > '#{chef_json_path}'",
      :input => 
%({
  "chef": {
    "server_url": "http://localhost:4000",
    "server_fqdn": "http://chef.easylodge.com.au",
    "webui_enabled": true,
    "init_style": "init",
    "client_interval": 1800
  },
  "run_list": [ "recipe[chef::bootstrap_server]" ]
}),
      :sudo => false
    )
  }
}
