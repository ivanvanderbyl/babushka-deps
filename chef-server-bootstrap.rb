dep('bootstrap chef server with rubygems') {
  requires [
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'chef.gem',
    'ohai.gem',
    'chef solo configuration',
    'chef bootstrap configuration'
  ],
  meet {
    log_shell "Downloading and running bootstrap", 
        "chef-solo -c /etc/chef/solo.rb -j ~/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-#{var(:chef_version)}.tar.gz", 
        :spinner => true, 
        :sudo => !File.writable?("/etc/chef/solo.rb")
  },
  met?{
    
  }
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
  installs "chef #{var(:chef_version, :default => "0.10.0")}"
  provides 'chef-client'
}

dep('ohai.gem') {
  installs 'ohai'
}

dep('chef solo configuration') {
  met?{ File.exists?("/etc/chef/solo.rb") }
  meet {
    shell("mkdir -p /etc/chef", :sudo => true)
    render_erb 'chef/solo.rb.erb', :to => '/etc/chef/solo.rb', :perms => '755', :sudo => true
  }
}

dep('chef bootstrap configuration') {
  define_var :init_style,
    :message => "Which init style would you like to use?",
    :default => 'init',
    :choice_descriptions => {
      'init' => 'Uses init scripts that are included in the chef gem. Logs will be in /var/log/chef. Only usable with debian/ubuntu and red hat family distributions.',
      'runit' => 'Uses runit to set up the service. Logs will be in /etc/sv/chef-client/log/main.',
      'bluepill' => 'Uses bluepill to set up the service.',
      'daemontools' => 'uses daemontools to set up the service. Logs will be in /etc/sv/chef-client/log/main.',
      'bsd' => 'Prints a message with the chef-client command to use in rc.local.'
    }
  
  define_var :web_ui_enabled,
    :message => "Enable Chef Web UI?",
    :default => "Y",
    :choice_descriptions => {
      'Y' => "Enabled",
      'N' => "Disabled"
    }
    
  def chef_json_path
    File.expand_path("~/chef.json")
  end
  
  def hostname
    var(:hostname, :default => shell('hostname -f'))
  end
  
  met?{ File.exists?(chef_json_path) }
  meet {
    json = {
      "chef"=>{
        "server_url"=>"http://localhost:4000", 
        "server_fqdn"=> hostname, 
        "webui_enabled"=> var(:web_ui_enabled).upcase == "Y",
        "init_style"=> var(:init_style),
        "client_interval"=>1800
      }, 
      "run_list"=>["recipe[chef::bootstrap_server]"]
    }.to_json
    
    shell("cat > '#{chef_json_path}'",
      :input => json,
      :sudo => false
    )
  }
}
