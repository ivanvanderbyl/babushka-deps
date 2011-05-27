dep 'core software' do
  requires {
    on :linux, 'vim.managed', 'curl.managed', 'htop.managed', 'jnettop.managed', 'screen.managed', 'nmap.managed', 'tree.managed'
    on :osx, 'curl.managed', 'htop.managed', 'jnettop.managed', 'nmap.managed', 'tree.managed'
  }
end

dep 'tree.managed'
dep 'vim.managed'
dep 'wget.managed'
dep 'zlib headers.managed' do
  installs { via :apt, 'zlib1g-dev' }
  provides []
end
