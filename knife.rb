meta :knife do
  def knife_directory
    File.expand_path("~/.chef")
  end
  
  def me
    shell('whoami')
  end
end

dep('knife client') { requires 'knife client registered.knife'}

dep('knife client registered.knife') {
  requires "knife configured.knife"
  
  met?{
    File.exists?(knife_directory / "deploy.pem") and
    shell('knife client list').p and
    shell("knife client list |grep -E '#{shell('whoami')}$'").p
  }
  
  meet {
    # shell("knife client create #{me} -c #{knife_directory}/knife_initial.rb")
    shell("sudo knife configure -i --defaults -r #{var(:chef_git_repository_url)} --no-editor -y", :sudo => true, :as => me).p
  }
}

dep('knife configured.knife'){
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
