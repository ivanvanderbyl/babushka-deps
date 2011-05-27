# echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list
# apt-get install wget
# sudo apt-get install vim
# wget -qO - http://apt.opscode.com/packages@opscode.com.gpg.key | sudo apt-key add -
# sudo apt-get update
# sudo apt-get install chef

dep("chef server") {
  requires 'opscode apt source added'
}

dep("opscode apt source added") {
  requires {
    on :ubuntu, 'wget.managed'
  }
  
  met? { File.exists? "/etc/apt/sources.list.d/opscode.list" }
  
  meet {
    shell 'echo "deb http://apt.opscode.com/ `lsb_release -cs`-0.10 main" | sudo tee /etc/apt/sources.list.d/opscode.list'
    shell 'wget -qO - http://apt.opscode.com/packages@opscode.com.gpg.key | sudo apt-key add -'
    shell 'sudo apt-get update'
  }
}

dep 'wget.managed' do
  installs {
    via :apt, 'wget'
  }
  provides "wget"
end

dep('vim.managed') {
  installs {
    via :apt, 'vim'
  }
  provides 'vim'
}

dep('chef.managed') {
  installs {
    via :apt, 'chef'
  }
  provides %w(chef-client knife)
}

dep('chef server.managed') {
  requires 'chef.managed'
  installs {
    via :apt, 'chef-server'
  }
  provides %w(chef-client knife chef-server chef-server-api chef-server-webui chef-solr chef-expander)
}
