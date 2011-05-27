dep 'core software' do
  requires {
    on :linux, 'vim.managed', 'curl.managed', 'htop.managed', 'jnettop.managed', 'screen.managed', 'nmap.managed', 'tree.managed'
  }
end

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
dep 'nmap.managed'
dep 'screen.managed'
dep 'jnettop.managed' do
  installs { via :apt, 'jnettop' }
end
dep 'htop.managed'
dep 'tree.managed'
dep 'vim.managed'
dep 'wget.managed'
dep 'zlib headers.managed' do
  installs { via :apt, 'zlib1g-dev' }
  provides []
end

dep 'sshd.managed' do
  installs {
    via :apt, 'openssh-server'
  }
end
