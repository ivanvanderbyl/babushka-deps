meta :knife do
  def knife_directory
    File.expand_path("~/.chef")
  end
  
  def me
    shell('whoami')
  end
end

meta :registered do
end

# This creates a new client to be copied to your local workstation
dep('external admin client.registered') {
  define_var(:local_username, :default => "bob", :message => "What is your workstation username?")
  
  met? {
    shell("knife client show #{var(:local_username)}")
  }
  
  meet {
    shell("rm -f /tmp/#{var(:local_username)}.pem")
    shell("knife client create #{var(:local_username)} -n -a -f /tmp/#{var(:local_username)}.pem")
  }
  
  after {
    log("You're client has been registered with Chef Server successfully. You now need to copy the new private key to your local workstation")
    log("Run this on your workstation:")
    log("scp #{shell("whoami")}@#{hostname}:/tmp/#{var(:local_username)}.pem ~/.chef/#{var(:local_username)}.pem")
  }
}

# This creates a new client for an external server
dep('external client.registered') {
  meet {
    # chef_server_url
    
  }
}

# This creates a new admin client on the chef server as your *deploy* user
# This allows you to use knife to run the above commands
dep('local admin client.registered') {
  requires "knife client configured.knife"
}

dep('registered knife client') { requires 'knife client registered.knife'}

dep('knife client configured.knife') {
  requires "knife configuration.knife"
  
  met?{
    File.exists?(knife_directory / "#{me}.pem") and
    shell('knife client list').p and
    shell("knife client list |grep -E '#{me}$'").p
  }
  
  meet {
    shell("sudo knife configure -i --defaults -r #{var(:chef_git_repository_url)} --no-editor -y -u #{me}", :sudo => true, :as => me).p
  }
}

dep('knife configuration.knife'){
  requires [
    'chef server keys.knife'
  ]
  
  met?{
    File.exists?(knife_directory / 'knife.rb')
  }
  
  meet {
    render_erb 'chef/knife.rb.erb', :to => knife_directory / 'knife.rb', :perms => '755', :sudo => false
  }
}

dep('chef server keys.knife') {
  requires ['dot chef directory.knife']
  
  met? {
    File.exists?(knife_directory / 'webui.pem') and
    File.exists?(knife_directory / 'validation.pem')
  }
  
  meet {
    shell("cp /etc/chef/validation.pem /etc/chef/webui.pem #{knife_directory}", :sudo => true)
  }
}

dep('dot chef directory.knife') {
  met?{
    File.exists?(knife_directory) and
    File.writable?(knife_directory)
  }
  
  meet {
    shell("mkdir -p #{knife_directory}")
    shell("chown -R $USER #{knife_directory}", :sudo => true)
  }
}
