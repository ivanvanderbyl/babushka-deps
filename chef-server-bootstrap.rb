meta :chef do
  def chef_json_path
    File.expand_path("~/chef.json")
  end
  
  def hostname
    var(:hostname, :default => shell('hostname -f'))
  end
  
  def is_listening_on_port?(port)
    shell "netstat -an | grep -E '^tcp.*[.:]#{port} +.*LISTEN'"
  end
  
  def is_process_with_name?(name)
    shell "ps -u chef -f |grep -E '(^chef)?.(#{name})'"
  end
  
  def chef_server_running?
    # is_process_with_name?("chef-server (api) : worker") and
    is_listening_on_port?("4000")
  end
  
  def chef_web_ui_running?
    is_listening_on_port?("4040")
  end
  
  def chef_rabbitmq_running?
    is_listening_on_port?("5672") and
    is_listening_on_port?("4369")
  end
  
  def chef_solr_running?
    is_listening_on_port?("8983")
  end
  
  def chef_couchdb_running?
    is_listening_on_port?("5984")
  end
  
  def web_ui_enabled?
    confirm("Enable Chef Web UI (chef-server-webui)", :default => 'y', :otherwise => "Skipping web UI")
  end
end

dep('bootstrap chef server with rubygems') {
  define_var(:chef_version, :defailt => "0.10.0", :message => "What version of Chef do you want to install?")
  
  requires [
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'gems.chef',
    'chef solo configuration.chef',
    'chef bootstrap configuration.chef',
    'bootstrapped chef installed.chef',
    'local admin client.registered'
  ]
  
  setup {
    set :server_install, true
    unmeetable "This dep cannot be run as root. Please run as your chef user, which can be setup using the dep 'chef user'" if shell('whoami') == 'root'
  }
}

dep('bootstrapped chef') { requires 'bootstrap chef server with rubygems' }

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

dep('gems.chef') {
  requires ['chef.gem', 'ohai.gem']
}

dep('chef.gem'){
  installs "chef #{var(:chef_version)}"
  provides 'chef-client'
}

dep('ohai.gem') {
  installs 'ohai'
}

dep('chef solo configuration.chef') {
  met?{ File.exists?("/etc/chef/solo.rb") }
  meet {
    shell("mkdir -p /etc/chef", :sudo => true)
    render_erb 'chef/solo.rb.erb', :to => '/etc/chef/solo.rb', :perms => '755', :sudo => true
  }
}

dep('chef bootstrap configuration.chef') {
  require "rubygems"
  require "json"
  
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
  
  met?{ File.exists?(chef_json_path) }
  meet {
    json = {
      "chef"=>{
        "server_url"=>"http://localhost:4000", 
        "server_fqdn"=> hostname, 
        "webui_enabled"=> web_ui_enabled?,
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

dep('bootstrapped chef installed.chef') {
  meet {
    log_shell "Downloading and running bootstrap", 
        "chef-solo -c /etc/chef/solo.rb -j ~/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-#{var(:chef_version)}.tar.gz", 
        :spinner => true, 
        :sudo => !File.writable?("/etc/chef/solo.rb")
  }
  
  met?{
    success = in_path?("chef-client >= #{var(:chef_version)}")
    
    if var(:server_install) == true
      success &= in_path?("chef-server")
      success &= in_path?("chef-solr >= #{var(:chef_version)}")
      success &= (web_ui_enabled? ? (chef_web_ui_running? and in_path?("chef-server-webui")) : true)
      success &= chef_server_running?
      success &= chef_rabbitmq_running?
      success &= chef_solr_running?
      success &= chef_couchdb_running?
    end
    return success
  }
}
