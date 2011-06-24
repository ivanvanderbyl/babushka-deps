dep 'chef user' do
  requires [
    'system',
    'admins can sudo',
    'user exists with password',
    'can sudo without password',
    'passwordless ssh logins',
    'secured system'
  ]
end

dep('can sudo without password') {
  requires 'sudo'
  met? { !sudo('cat /etc/sudoers').split("\n").grep(/(^#{var(:username, :default => 'chef')})?.(NOPASSWD:ALL)/).empty? }
  meet { append_to_file "#{var(:username)}  ALL=(ALL) NOPASSWD:ALL", '/etc/sudoers', :sudo => true }
}

dep 'passwordless ssh logins' do
  def ssh_dir
    "/home/#{var(:username, :default => 'chef')}" / '.ssh'
  end
  def group
    shell "id -gn #{var(:username)}"
  end

  requires 'public key'

  met? {
    sudo "mkdir -p '#{ssh_dir}'"
    shell("touch '#{ssh_dir / 'authorized_keyss'}'")
    sudo "grep '#{var(:your_ssh_public_key)}' '#{ssh_dir / 'authorized_keys'}'"
  }
  before {
    sudo "mkdir -p '#{ssh_dir}'"
    sudo "chmod 700 '#{ssh_dir}'"
  }
  meet {
    append_to_file var(:your_ssh_public_key), (ssh_dir / 'authorized_keys'), :sudo => true
  }
  after {
    sudo "chown -R #{var(:username)}:#{group} '#{ssh_dir}'"
    sudo "chmod 600 #{(ssh_dir / 'authorized_keys')}"
  }
end

dep 'public key' do
  def ssh_dir
    "/home/#{var(:username, :default => 'deploy')}" / '.ssh'
  end
  met? { grep /^ssh-rsa/, ssh_dir + '/id_rsa.pub' }
  meet {
    log shell("ssh-keygen -t rsa -f #{ssh_dir}/id_rsa -N ''", :sudo => true, :as => var(:username))
  }
end

dep 'dot files' do
  requires 'user exists', 'git', 'curl.managed', 'git-smart.gem'
  met? { File.exists?(ENV['HOME'] / ".dot-files/.git") }
  meet { shell %Q{curl -L "http://github.com/#{var :github_user, :default => 'benhoskings'}/#{var :dot_files_repo, :default => 'dot-files'}/raw/master/clone_and_link.sh" | bash} }
end

dep 'user exists with password' do
  requires 'user exists'
  on :linux do
    met? { shell('sudo cat /etc/shadow')[/^#{var(:username, :default => 'chef')}:[^\*!]/] }
    meet {
      sudo "echo -e '#{var(:password)}\n#{var(:password)}' | passwd #{var(:username)}"
    }
  end
end

dep 'user exists' do
  def username
    var(:username, :default => 'deploy')
  end
  setup {
    unmeetable("You cannot call your user 'chef' - this name is reserved for chef") if username == "chef"
    define_var :home_dir_base, :default => L{
      username['.'] ? '/srv/http' : '/home'
    }
  }
  on :linux do
    met? { grep(/^#{username}:/, '/etc/passwd') }
    meet {
      sudo "mkdir -p #{var :home_dir_base}" and
      sudo "useradd -m -s /bin/bash -b #{var :home_dir_base} -G admin #{var(:username)}" and
      sudo "chmod 701 #{var(:home_dir_base) / var(:username)}"
    }
  end
end
