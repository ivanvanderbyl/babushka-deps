def ssh_conf_path file
  "/etc#{'/ssh' if Babushka::Base.host.linux?}/#{file}_config"
end

dep 'system' do
  requires 'set.locale', 'hostname', 'tmp cleaning grace period', 'core software'
end

dep 'secured system' do
  requires 'secured ssh logins', 'lax host key checking', 'admins can sudo'
  setup {
    unmeetable "This dep has to be run as root." unless shell('whoami') == 'root'
  }
end

dep 'tmp cleaning grace period', :for => :ubuntu do
  met? { !grep(/^[^#]*TMPTIME=0/, "/etc/default/rcS") }
  meet { change_line "TMPTIME=0", "TMPTIME=30", "/etc/default/rcS" }
end

dep 'secured ssh logins' do
  requires 'sshd.managed'
  met? {
    # -o NumberOfPasswordPrompts=0
    output = failable_shell('ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no nonexistentuser@localhost').stderr
    if output.downcase['connection refused']
      log_ok "sshd doesn't seem to be running."
    elsif (auth_methods = output.scan(/Permission denied \((.*)\)\./).join.split(/[^a-z]+/)).empty?
      log_error "sshd returned unexpected output."
    else
      (auth_methods == %w[publickey]).tap {|result|
        log "sshd #{'only ' if result}accepts #{auth_methods.to_list} logins.", :as => (result ? :ok : :error)
      }
    end
  }
  meet {
    change_with_sed 'PasswordAuthentication',          'yes', 'no', ssh_conf_path(:sshd)
    change_with_sed 'ChallengeResponseAuthentication', 'yes', 'no', ssh_conf_path(:sshd)
  }
  after { sudo "/etc/init.d/ssh restart" }
end

dep 'lax host key checking' do
  requires 'sed.managed'
  met? { grep /^StrictHostKeyChecking[ \t]+no/, ssh_conf_path(:ssh) }
  meet { change_with_sed 'StrictHostKeyChecking', 'yes', 'no', ssh_conf_path(:ssh) }
end
