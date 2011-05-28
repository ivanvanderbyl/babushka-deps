meta :knife do
  def knife_directory
    File.expand_path("~/.chef")
  end
  
  def me
    shell('whoami')
  end
end

dep('knife configured.knife'){
  requires [
    'chef server keys.knife'
  ]
  
  met?{
    shell('knife client list') and
    shell("knife client list |grep -E '#{shell('whoami')}$'")
  }
  meet {
    render_erb 'chef/knife.rb.erb', :to => knife_directory / 'solo.rb', :perms => '755', :sudo => false
    shell("knife client create #{me} -a -c #{knife_directory}/knife.rb --no-editor -f #{knife_directory}/#{me}.pem")
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

dep('chef server keys.knife') {
  requires ['dot chef directory.knife']
  
  meet {
    shell("cp /etc/chef/validation.pem /etc/chef/webui.pem #{knife_directory}", :sudo => true)
  }
}
