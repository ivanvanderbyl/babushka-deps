dep('bootstrap chef server with rubygems') {
  requires [
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'chef.gem',
    'ohai.gem',
    'chef solo bootstap'
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
  installs "chef #{var(:chef_version, :default => "0.9.16")}"
  provides 'chef-client'
}

dep('ohai.gem') {
  installs 'ohai'
}

dep('chef solo bootstap') {
  requires [
    'chef solo configuration',
    'chef bootstrap configuration'
  ]
  met? {
    false
  }
  meet {
    shell("mkdir -p #{File.expand_path("~/")}/chef-src", :sudo => !File.writable?(File.expand_path("~/")))
    log_shell "Downloading bootstrap version #{var(:chef_version, :default => "0.9.16")}", "wget http://s3.amazonaws.com/chef-solo/bootstrap-#{var(:chef_version)}.tar.gz -O ~/chef-src/bootstrap.tar.gz" 
    # if var(:chef_version).to_f < 0.10
    #   shell("touch /etc/chef/server.rb", :sudo => true)
    #   shell("ln -s /etc/chef/server.rb /etc/chef/webui.rb", :sudo => true)
    # end
    log_shell "Bootstrapping Chef", "chef-solo -c /etc/chef/solo.rb -j ~/chef.json ~/chef-src/bootstrap.tar.gz", :spinner => true, :sudo => !File.writable?("/etc/chef/solo.rb")
    
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
