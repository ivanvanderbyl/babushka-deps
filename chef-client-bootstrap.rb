dep('bootstrap chef client'){
  define_var(:chef_version, :defailt => "0.10.0", :message => "What version of Chef do you want to install?")
  
  setup {
    set :server_install, false
  }
  
  requires [
    'system',
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'gems.chef',
    'chef solo configuration.chef',
    'chef client bootstrap configuration.chef',
    'chef client configuration.chef',
    'bootstrapped chef installed.chef'
  ]
}

dep('chef client bootstrap configuration.chef') {
  require "rubygems"
  require "json"
  
  define_var(:chef_server_url, :default => "http://chef.example.com:4000", :message => "What is the URL of your main chef server?")
  
  met?{ File.exists?(chef_json_path) }
  meet {
    shell("export CHEF_SERVER=#{var(:chef_server_url)}")
    json = {
      "chef"=>{
        "server_fqdn"=> var(:chef_server_url), 
        "client_interval"=>1800
      },
      "recipes" => "chef::client"
    }.to_json
    
    shell("cat > '#{chef_json_path}'",
      :input => json,
      :sudo => false
    )
  }
}

dep('chef client configuration.chef'){
  met?{ File.exists?("/etc/chef/client.rb") }
  meet {
    shell("mkdir -p /etc/chef", :sudo => true)
    render_erb 'chef/client.rb.erb', :to => '/etc/chef/client.rb', :perms => '755', :sudo => true
  }
}